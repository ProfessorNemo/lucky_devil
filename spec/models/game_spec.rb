# frozen_string_literal: true

RSpec.describe Game, type: :model do
  let(:user) { create(:user) }

  let(:game_w_questions) do
    create(:game_with_questions, user: user)
  end

  context 'Game Factory' do
    it 'Game.create_game! new correct game' do
      generate_questions(60)

      game = nil

      # какие изменения этот блок произвел в базе, т.е. сколько новых
      # объектов было создано
      expect do
        game = described_class.create_game_for_user!(user)
      end.to change(described_class, :count).by(1)
                                            .and(change(GameQuestion, :count).by(15))

      expect(game.user).to eq(user)
      expect(game.status).to eq(:in_progress)

      expect(game.game_questions.size).to eq(15)
      expect(game.game_questions.map(&:level)).to eq (0..14).to_a
    end
  end

  context 'game mechanics' do
    it 'answer correct continues game' do
      level = game_w_questions.current_level
      # текущий вопрос
      q = game_w_questions.current_game_question
      # проверка "игра  только началась"
      expect(game_w_questions.status).to eq(:in_progress)

      # ответ правильный
      game_w_questions.answer_current_question!(q.correct_answer_key)

      # изменился игровой уровень
      expect(game_w_questions.current_level).to eq(level + 1)
      # изменился текущий игровой вопрос
      expect(game_w_questions.current_game_question).not_to eq(q)
      # игра продолжается
      expect(game_w_questions.status).to eq(:in_progress)
      # игра не закончена
      expect(game_w_questions).not_to be_finished
    end

    it '#take_money! finishes the game' do
      q = game_w_questions.current_game_question
      game_w_questions.answer_current_question!(q.correct_answer_key)

      game_w_questions.take_money!

      prize = game_w_questions.prize
      expect(prize.positive?).to be(true)

      expect(game_w_questions.status).to eq(:money)
      expect(game_w_questions.finished?).to be(true)
      expect(user.balance).to eq prize
    end

    specify '#current_game_question' do
      expect(game_w_questions.current_game_question).to be_a(GameQuestion)
    end

    specify '#previous_level' do
      expect(game_w_questions.previous_level).to eq(game_w_questions.current_level - 1)
    end
  end

  describe '#status' do
    context 'when the game is finished' do
      before { game_w_questions.finished_at = Time.zone.now }

      it 'finishes game with a fail status' do
        game_w_questions.is_failed = true
        expect(game_w_questions.status).to eq(:fail)
      end

      it 'finishes the game with timeout status' do
        game_w_questions.created_at = 2.hours.ago
        game_w_questions.is_failed = true
        expect(game_w_questions.status).to eq(:timeout)
      end

      it 'finishes game with won status' do
        game_w_questions.current_level = Question::QUESTION_LEVELS.max + 1
        expect(game_w_questions.status).to eq(:won)
      end

      it 'finishes game with money status' do
        expect(game_w_questions.status).to eq(:money)
      end
    end
  end

  describe '.answer_current_question!' do
    context 'when answer is correct' do
      let(:q) { game_w_questions.current_game_question }

      it 'continues the game with in_progress status' do
        expect(game_w_questions.answer_current_question!('d')).to be(true)
        expect(game_w_questions.status).to eq(:in_progress)
        expect(game_w_questions.finished?).to be(false)
      end

      context 'and the question is last' do
        before do
          game_w_questions.current_level = Question::QUESTION_LEVELS.max
          game_w_questions.answer_current_question!(q.correct_answer_key)
          game_w_questions.take_money!
          game_w_questions.finished_at = Time.zone.now
        end

        it 'finishes the game with won status' do
          expect(game_w_questions.status).to eq(:won)
          expect(game_w_questions.finished?).to be(true)
        end

        it 'assigns the maximum prize' do
          expect(game_w_questions.prize).to eq(Game::PRIZES.last)
        end
      end

      context 'and the time is out' do
        it 'finishes game with a timeout status' do
          game_w_questions.created_at = 50.minutes.ago

          expect(game_w_questions.answer_current_question!('d')).to be(false)
          expect(game_w_questions.status).to eq(:timeout)
          expect(game_w_questions.finished?).to be(true)
        end
      end
    end

    context 'when answer is wrong' do
      let(:correct_answer_key) do
        game_w_questions.current_game_question.correct_answer_key
      end

      let!(:wrong_answer_key) do
        %w[a b c d].reject { |w| w == correct_answer_key }.sample
      end

      before do
        game_w_questions.current_level = Game::FIREPROOF_LEVELS.max
        game_w_questions.answer_current_question!(wrong_answer_key)
      end

      it 'finishes game with status fail' do
        expect(game_w_questions.finished_at).to be_truthy
        expect(game_w_questions.is_failed).to be(true)
        expect(game_w_questions.status).to eq(:fail)
      end

      it 'gets garant prize' do
        expect(game_w_questions.is_failed).to be(true)
        expect(game_w_questions.prize).to eq(32_000)
      end
    end
  end
end
