# frozen_string_literal: true

# Тест на шаблон users/index.html.erb

RSpec.describe 'users/index' do
  # Перед каждым шагом мы пропишем в переменную @users пару пользователей
  # как бы имитируя действие контроллера, который эти данные будет брать из базы
  # Обратите внимание, что мы объекты в базу не кладем, т.к. пишем FactoryBot.build_stubbed
  before do
    assign(:users, [
             build_stubbed(:user, name: 'User1', balance: 1000),
             build_stubbed(:user, name: 'User2', balance: 2000)
           ])

    render
  end

  # Проверяем, что шаблон выводит имена игроков
  it 'render player names' do
    expect(rendered).to match('User1')
    expect(rendered).to match('User2')
  end

  # Проверяем, что шаблон выводит балансы игроков
  it 'render player balances' do
    expect(rendered).to match('1 000 ₽')
    expect(rendered).to match('2 000 ₽')
  end

  # Проверяем, что шаблон выводит игроков в нужном порядке
  # (вообще говоря, тест избыточный, т.к. за порядок объектов в @users отвечает контроллер,
  # но чтобы показать, как тестировать порядок элементов на странице, полезно)
  it 'render player names in right order' do
    expect(rendered).to match(/User1.*User2/m)
  end
end
