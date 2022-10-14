# frozen_string_literal: true

# Тест на фрагмент users/_game.html.erb, который выводит
# информацию о конкретной игре на странице профиля

RSpec.describe 'users/_game', type: :view do
  # Подготовим объект game для использования в тестах, где он понадобится
  # обратите внимание, что build_stubbed не создает объект в базе (id вручную создаем)
  let(:game) do
    build_stubbed(
      :game, id: 5, created_at: Time.zone.parse('2022.01.01, 12:00'), current_level: 10, prize: 1000
    )
  end

  # Этот код будет выполнен перед каждым it-ом
  before do
    # Разрешаем объекту game в ответ на вызов метода status возвращать символ :in_progress
    allow(game).to receive(:status).and_return(:in_progress)

    # Рендерим наш фрагмент с нужным объектом
    render partial: 'users/game', object: game
  end

  # Проверяем, что фрагмент выводит id игры
  it 'render game id' do
    expect(rendered).to match('5')
  end

  # Проверяем, что фрагмент выводит время начала игры
  it 'render game start time' do
    expect(rendered).to match('01 янв., 12:00')
  end

  # Проверяем, что фрагмент выводит текущий уровень
  it 'render current question level' do
    expect(rendered).to match('10')
  end

  # Проверяем, что фрагмент выводит статус игры
  it 'render game status' do
    expect(rendered).to match('в процессе')
  end

  # Проверяем, что фрагмент выводит текущий выигрыш игрока
  it 'render game prize' do
    expect(rendered).to match('1 000 ₽')
  end
end