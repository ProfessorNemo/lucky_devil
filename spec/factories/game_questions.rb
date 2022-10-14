# frozen_string_literal: true

FactoryBot.define do
  factory :game_question do
    a { 4 }
    b { 3 }
    c { 2 }
    d { 1 }

    # Связь с игрой и вопросом.
    # Если при создании game_question не указать явно объекты Игра и Вопрос,
    # наша фабрика сама создаст и пропишет нужные объекты, используя фабрики
    # с именами :game и :question
    association :game, factory: :game
    association :question, factory: :question
  end
end

# "game_question" - зависимая модель и принадлежит (belongs_to) game и user
