# frozen_string_literal: true

# Модель игры — создается когда пользователь начинает новую игру
# Хранит/обновляет состояние игры и отвечает за игровой процесс.
class Game < ApplicationRecord
  # денежный приз за каждый вопрос
  PRIZES = [
    100, 200, 300, 500, 1000,
    2000, 4000, 8000, 16_000, 32_000,
    64_000, 125_000, 250_000, 500_000, 1_000_000
  ].freeze

  # номера несгораемых уровней
  FIREPROOF_LEVELS = [4, 9, 14].freeze

  # время на одну игру
  TIME_LIMIT = 40.minutes

  belongs_to :user

  # массив игровых вопросов для этой игры
  has_many :game_questions, dependent: :destroy

  # текущий вопрос (его уровень сложности)
  validates :current_level, numericality: { only_integer: true }, allow_nil: false

  # выигрыш игрока - от нуля до максимального приза за игру
  validates :prize,
            presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: PRIZES.last }

  # Scope - подмножество игр, у которых поле finished_at пустое
  scope :in_progress, -> { where(finished_at: nil) }

  #---------  Фабрика-генератор новой игры ------------------------------

  # returns correct new game or dies with exceptions
  def self.create_game_for_user!(user)
    # внутри единой транзакции
    transaction do
      game = create!(user: user)

      # созданной игре добавляем ровно 15 новых игровых вопросов, выбирая случайный Question из базы
      Question::QUESTION_LEVELS.each do |i|
        q = Question.where(level: i).order('RANDOM()').first
        ans = [1, 2, 3, 4]
        game.game_questions.create!(question: q, a: ans.shuffle!.pop, b: ans.shuffle!.pop, c: ans.shuffle!.pop,
                                    d: ans.shuffle!.pop)
      end
      game
    end
  end

  #---------  Основные методы доступа к состоянию игры ------------------

  # последний отвеченный вопрос игры, *nil* для новой игры!
  def previous_game_question
    current_update_need(previous_level)
  end

  # текущий, еще неотвеченный вопрос игры
  def current_game_question
    current_update_need(current_level)
  end

  # -1 для новой игры!
  def previous_level
    current_level - 1
  end

  # Игра закончена, если прописано поле :finished_at - время конца игры
  def finished?
    finished_at.present?
  end

  # проверяет текущее время и грохает игру + возвращает true если время прошло
  def time_out!
    return unless (Time.zone.now - created_at) > TIME_LIMIT

    finish_game!(fire_proof_prize(previous_level), true)
    true
  end

  #---------  Основные игровые методы ------------------------------------

  # возвращает true — если ответ верный,
  # текущая игра при этом обновляет свое состояние:
  #   меняется :current_level, :prize (если несгораемый уровень), поля :updated_at
  #   прописывается :finished_at если это был последний вопрос
  #
  # возвращает false — если 1) ответ неверный 2) время вышло 3) игра уже закончена ранее
  #   в любом случае прописывается :finished_at, :prize (если несгораемый уровень), :updated_at
  # После вызова этого метода обновится status игры
  #
  # letter = 'a','b','c' или 'd'
  def answer_current_question!(letter)
    return false if time_out! || finished? # законченную игру низя обновлять

    if current_game_question.answer_correct?(letter)
      self.current_level += 1
      if current_level == Question::QUESTION_LEVELS.max
        finish_game!(PRIZES[Question::QUESTION_LEVELS.max], false)
      else
        save!
      end

      true
    else
      finish_game!(fire_proof_prize(previous_level), true)
      false
    end
  end

  # Записываем юзеру игровую сумму на счет и завершаем игру,
  def take_money!
    return if time_out! || finished? # из законченной или неначатой игры нечего брать

    finish_game!(previous_level > -1 ? PRIZES[previous_level] : 0, false)
  end

  # Создает варианты подсказок для текущего игрового вопроса.
  # Возвращает true, если подсказка применилась успешно,
  # false если подсказка уже заюзана.
  #
  # rubocop:disable all
  # help_type = :fifty_fifty | :audience_help | :friend_call | :replacement_question
  def use_help(help_type)
    case help_type
    when :fifty_fifty
      # если этот фложок в БД 'false', то переключаем его с пом-ю м-да toggle! в 'true'
      # ('!') - сразу сохраняем в базе
      unless fifty_fifty_used
        # ActiveRecord метод "toggle!"" переключает булевое поле сразу в базе
        toggle!(:fifty_fifty_used)
        current_game_question.add_fifty_fifty
        return true
      end
    when :audience_help
      unless audience_help_used
        toggle!(:audience_help_used)
        current_game_question.add_audience_help
        return true
      end
    when :friend_call
      unless friend_call_used
        toggle!(:friend_call_used)
        current_game_question.add_friend_call
        return true
      end
    when :replacement_question
      unless replacement_question_used
        toggle!(:replacement_question_used)
        current_game_question.add_replacement_question
        return true
      end
    end

    false
  end

  # Результат игры, одно из:
  # :fail - игра проиграна из-за неверного вопроса
  # :timeout - игра проиграна из-за таймаута
  # :won - игра выиграна (все 15 вопросов покорены)
  # :money - игра завершена, игрок забрал деньги
  # :in_progress - игра еще идет
  def status
    return :in_progress unless finished?

    if is_failed
      if (finished_at - created_at) <= TIME_LIMIT
        :fail
      else
        :timeout
      end
    elsif current_level > Question::QUESTION_LEVELS.max
      :won
    elsif current_level == 0
      :fail
    else
      :money
    end
  end

  private

  # Метод завершатель игры
  # Обновляет все нужные поля и начисляет юзеру выигрыш
  def finish_game!(amount = 0, failed = true)
    # оборачиваем в транзакцию - игра заканчивается
    # и баланс юзера пополняется только вместе
    transaction do
      self.prize = amount
      self.finished_at = Time.zone.now
      self.is_failed = failed
      user.balance += amount
      save!
      user.save!
    end
  end
  # rubocop:enable all

  # По заданному уровню вопроса вычисляем вознаграждение за ближайшую несгораемую сумму
  # noinspection RubyArgCount
  def fire_proof_prize(answered_level)
    lvl = FIREPROOF_LEVELS.reverse.find { |x| x <= answered_level }
    lvl.present? ? PRIZES[lvl] : 0
  end

  def current_update_need(level)
    # с помощью ruby метода detect находим в массиве game_questions нужный вопрос
    current = game_questions.detect { |q| q.question.level == level }
    if replacement_question_used.blank?
      current
    else
      current.update question: Question.where(level: level).order('RANDOM()').first
      current.reload
    end
  end
end
