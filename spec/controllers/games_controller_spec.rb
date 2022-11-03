# frozen_string_literal: true

# Тестовый сценарий для игрового контроллера
# Самые важные здесь тесты:
#   1. на авторизацию (чтобы к чужим юзерам не утекли не их данные)
#   2. на четкое выполнение самых важных сценариев (требований) приложения
#   3. на передачу граничных/неправильных данных в попытке сломать контроллер

RSpec.describe GamesController do
  # обычный пользователь
  let(:user) { create(:user) }
  # админ
  let(:admin) { create(:user, is_admin: true) }
  # игра с прописанными игровыми вопросами
  let(:game_w_questions) { create(:game_with_questions, user: user) }

  # группа тестов для незалогиненного юзера (Анонимус)
  context 'when the user is not logged in' do
    # из экшена show анона посылаем
    it 'kick from #show' do
      # вызываем экшен
      get :show, params: { id: game_w_questions.id }

      # проверяем ответ
      expect(response).not_to have_http_status(:ok) # статус не 200 ОК
      expect(response).to redirect_to(new_user_session_path) # devise должен отправить на логин
      expect(flash[:alert]).not_to be_nil # во flash должен быть прописана ошибка
    end

    it 'kick from #create' do
      post :create

      expect(response).not_to have_http_status(:ok)
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).not_to be_nil
    end

    it 'kick from #answer' do
      put :answer, params: { id: 1, letter: 'a' }

      expect(response).not_to have_http_status(:ok)
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).not_to be_nil
    end

    it 'kick from #take_money' do
      put :take_money, params: { id: 1 }

      expect(response).not_to have_http_status(:ok)
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).not_to be_nil
    end

    it 'kick from #help' do
      put :help, params: { id: 1 }

      expect(response).not_to have_http_status(:ok)
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).not_to be_nil
    end
  end

  # группа тестов на экшены контроллера, доступных залогиненным юзерам
  context 'when user is logged in' do
    # перед каждым тестом в группе
    before { sign_in user } # логиним юзера user с помощью спец. Devise метода sign_in

    # юзер может создать новую игру
    it 'creates the game' do
      # сперва накидаем вопросов, из чего собирать новую игру
      generate_questions(15)

      post :create
      game = assigns(:game) # вытаскиваем из контроллера поле @game (instance variables)

      # проверяем состояние этой игры
      expect(game.finished?).to be(false)
      expect(game.user).to eq(user)
      # и редирект на страницу этой игры
      expect(response).to redirect_to(game_path(game))
      expect(flash[:notice]).not_to be_nil
    end

    # юзер видит свою игру
    it '#show game' do
      get :show, params: { id: game_w_questions.id }
      game = assigns(:game) # вытаскиваем из контроллера поле @game
      expect(game.finished?).to be(false)
      expect(game.user).to eq(user)

      expect(response).to have_http_status(:ok) # должен быть ответ HTTP 200
      expect(response).to render_template('show') # и отрендерить шаблон show
    end

    # юзер отвечает на игру(вопрос) корректно - игра продолжается
    it 'answers correct' do
      # передаем параметр params[:letter]
      put :answer,
          params: { id: game_w_questions.id, letter: game_w_questions.current_game_question.correct_answer_key }
      game = assigns(:game)

      expect(game.finished?).to be(false)
      expect(game.current_level.positive?).to be(true)
      expect(response).to redirect_to(game_path(game))
      expect(flash.empty?).to be(true) # удачный ответ не заполняет flash
    end

    # проверка, что пользователя посылают из чужой игры
    it '#show alien game' do
      # создаем новую игру, юзер не прописан, будет создан фабрикой новый
      alien_game = create(:game_with_questions)

      # пробуем зайти на эту игру текущим залогиненным user
      get :show, params: { id: alien_game.id }

      expect(response).not_to have_http_status(:ok) # статус не 200 ОК
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).not_to be_nil # во flash должен быть прописана ошибка
    end

    # rubocop:disable all
    # юзер берет деньги
    it 'takes money' do
      # вручную поднимем уровень вопроса до выигрыша 200
      game_w_questions.update_attribute(:current_level, 2)

      put :take_money, params: { id: game_w_questions.id }
      game = assigns(:game)
      expect(game.finished?).to be(true)
      expect(game.prize).to eq(200)

      # пользователь изменился в базе, надо в коде перезагрузить!
      user.reload
      expect(user.balance).to eq(200)

      expect(response).to redirect_to(user_path(user))
      expect(flash[:warning]).not_to be_nil
    end
    # rubocop:enable all

    # юзер пытается создать новую игру, не закончив старую
    it 'try to create second game' do
      # убедились что есть игра в работе
      expect(game_w_questions.finished?).to be(false)
      # отправляем запрос на создание, убеждаемся что новых Game не создалось
      expect { post :create }.not_to change(Game, :count)

      game = assigns(:game) # вытаскиваем из контроллера поле @game
      expect(game).to be_nil

      # и редирект на страницу старой игры
      expect(response).to redirect_to(game_path(game_w_questions))
      expect(flash[:alert]).not_to be_nil
    end

    it 'call 50/50 help' do
      expect(game_w_questions.fifty_fifty_used).to be(false)
      expect(game_w_questions.current_game_question.help_hash[:fifty_fifty]).to be_nil

      put :help, params: { id: game_w_questions.id, help_type: :fifty_fifty }
      game = assigns(:game)

      expect(game.fifty_fifty_used).to be(true)
      expect(game.status).to be(:in_progress)

      # осталось 2 овета, один из которых верный
      expect(game.current_game_question.help_hash[:fifty_fifty].size).to eq(2)
      # содержит ключ правильног оответа
      expect(game.current_game_question.help_hash[:fifty_fifty])
        .to include(game.current_game_question.correct_answer_key)
      expect(response).to redirect_to(game_path(game))
    end

    # тест на отработку "помощи зала"
    it 'uses audience help' do
      # сперва проверяем что в подсказках текущего вопроса пусто
      expect(game_w_questions.current_game_question.help_hash[:audience_help]).to be_nil
      expect(game_w_questions.audience_help_used).to be_falsey

      # фигачим запрос в контроллер с нужным типом
      put :help, params: { id: game_w_questions.id, help_type: :audience_help }
      game = assigns(:game)

      # проверяем, что игра не закончилась, что флажок установился, и подсказка записалась
      expect(game.finished?).to be(false)
      expect(game.audience_help_used).to be_truthy
      expect(game.current_game_question.help_hash[:audience_help]).not_to be_nil
      expect(game.current_game_question.help_hash[:audience_help].keys).to contain_exactly('a', 'b', 'c', 'd')
      expect(response).to redirect_to(game_path(game))
    end

    context 'and the answer is wrong' do
      it 'finishes the game with fail status' do
        put :answer, params: { id: game_w_questions.id, letter: 'a' }
        game = assigns(:game)

        expect(game.status).to be(:fail)
        expect(game.finished?).to be(true)
      end

      it 'redirect to user path with alert message' do
        put :answer, params: { id: game_w_questions.id, letter: 'a' }

        expect(response).to redirect_to(user_path(user))
        expect(flash[:alert]).not_to be_nil
      end
    end
  end
end
