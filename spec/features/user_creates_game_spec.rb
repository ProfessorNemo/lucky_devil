# frozen_string_literal: true

RSpec.describe 'USER creates a game' do
  # Чтобы пользователь мог начать игру, нам надо
  # создать пользователя
  let(:user) { create(:user) }

  # и создать 15 вопросов с разными уровнями сложности
  # Обратите внимание, что текст вопроса и вариантов ответа нам
  # здесь важен, так как именно их мы потом будем проверяеть
  let(:questions) do
    (0..14).to_a.map do |i|
      create(
        :question, level: i,
                   text: "Когда была куликовская битва номер #{i}?",
                   answer1: '1380', answer2: '1381', answer3: '1382', answer4: '1383'
      )
    end
  end

  let(:game_w_questions) do
    create(:game_with_questions, user: user)
  end

  # Перед началом любого сценария нам надо авторизовать пользователя
  # и залить вопросы в бд
  before do
    questions.each(&:save) # либо это строка, либо "let!(:questions)"
    login_as user
  end

  # Сценарий успешного создания игры
  it 'successfully' do
    # Заходим на главную
    visit '/'

    expect(page).to have_current_path '/'

    # save_and_open_page

    # Кликаем по ссылке "Новая игра"
    click_link 'Новая игра'

    # Ожидаем, что попадем на нужный url
    expect(page).to have_current_path "/games/#{game_w_questions.id - 1}"

    # Ожидаем, что на экране вопрос игры (самый простой)
    expect(page).to have_content 'Когда была куликовская битва номер 0?'

    # Ожидаем, что на экране варианты ответа на вопрос
    expect(page).to have_content '1380'
    expect(page).to have_content '1381'
    expect(page).to have_content '1382'
    expect(page).to have_content '1383'
  end
end

# Методы 'capybara':
# "visit, click_link" - посетить страницу и кликнуть ссылку
# "fill_in ..., with" - заполнить поля форм данными
# "experct(page)" - проверять результат в вернувшейся странице на наличе тегов
# свойств, аттрибутов и т.д.

# В процессе работы можно использовать метод launchy -
# "save_and_open_page"
# в этот момент капибара сделает страницу того, что она видит,
# html-код сохранит, положит в файл и открое в браузере.
# но в конечном коде (который идет в репозиторий)
# этого кода быть не должно, также, как и byebug.
