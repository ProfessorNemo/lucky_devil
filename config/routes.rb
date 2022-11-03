# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'users#index'

  # Путь для админки
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  # Пути для формы регистрации, входа и т.д.
  devise_for :users

  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end

  # в профиле юзера показываем его игры, на главной - список лучших игроков
  resources :users, controller: :users, only: %i[index show]

  resources :games, only: %i[create show] do
    member do
      put 'help' # помощь зала
      put 'answer' # ответ на текущий вопрос
      put 'take_money' #  игрок берет деньги
    end
  end
  #
  # что эквивалентно:
  # get '/games/:id', to: 'games#show', as: :game
  # post '/games', to: 'games#create', as: :games
  # put '/games/:id/take_money', to: 'games#take_money', as: :take_money_game
  # put '/games/:id/answer', to: 'games#answer', as: :answer_game
  # put '/games/:id/help', to: 'games#help', as: :help_game

  # и эквивалентно:
  # get '/games/:id', action: :show, controller: 'games'
  # post '/games', action: :create, controller: 'games'
  # put '/games/:id/take_money', action: :take_money, controller: 'games', as: :take_money_game
  # put '/games/:id/answer', action: :answer, controller: 'games', as: :answer_game
  # put '/games/:id/help', action: :help, controller: 'games', as: :help_game

  # Ресурс в единственном числе - ВопросЫ
  # для загрузки админом сразу пачки вопросОВ
  resource :questions, only: %i[new create]
end
