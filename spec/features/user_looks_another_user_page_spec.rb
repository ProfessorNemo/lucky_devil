# frozen_string_literal: true

RSpec.describe 'USER looks another user page' do
  let(:user1) { create(:user, name: 'User_1') }
  let(:user2) { create(:user, name: 'User_2') }

  let!(:games) do
    [
      create(:game, id: 1, user: user2, current_level: 0, created_at: Time.zone.parse('19.09.2022, 14:00')),
      create(:game, id: 2, user: user2, prize: 1_000_000, current_level: 15,
                    created_at: Time.zone.parse('10.10.2022, 18:00'), finished_at: Time.zone.parse('10.10.2022, 18:20'))
    ]
  end

  before { login_as(user1) }

  it 'User_1 looks User_2 page' do
    visit '/'

    click_link 'User_2'

    expect(page).to have_current_path("/users/#{user2.id}")
    expect(page).not_to have_content('Сменить имя и пароль')
    expect(page).to have_content('User_2')

    expect(page).to have_content('#')
    expect(page).to have_content('Дата')
    expect(page).to have_content('Вопрос')
    expect(page).to have_content('Выигрыш')
    expect(page).to have_content('Подсказки')

    expect(page).to have_content('1')
    expect(page).to have_content('в процессе')
    expect(page).to have_content('19 сент., 14:00')
    expect(page).to have_content('0')
    expect(page).to have_content('0 ₽')

    expect(page).to have_content('2')
    expect(page).to have_content('победа')
    expect(page).to have_content('10 окт., 18:00')
    expect(page).to have_content('15')
    expect(page).to have_content('1 000 000 ₽')
  end
end
