# frozen_string_literal: true

RSpec.describe 'users/show', type: :view do
  context 'when the user views their own page' do
    before do
      user = assign(:user, build_stubbed(:user, name: 'User111'))
      allow(view).to receive(:current_user).and_return(user)

      render
    end

    it 'render user name' do
      expect(rendered).to match('User111')
    end

    it 'render change name and password link' do
      expect(rendered).to match('Сменить имя и пароль')
    end

    it 'render game partial' do
      assign(:games, [build_stubbed(:game, id: 55, created_at: 1.minute.ago, current_level: 5)])
      stub_template 'users/_game.html.erb' => 'User game goes here'
      render

      expect(rendered).to match('User game goes here')
    end
  end

  context 'when user views someone else page' do
    before do
      assign(:user, build_stubbed(:user, name: 'User222'))

      render
    end

    it 'render user name' do
      expect(rendered).to match('User222')
    end

    it 'not render change name and password link' do
      expect(rendered).not_to match('Сменить имя и пароль')
    end

    it 'render game partial' do
      assign(:games, [build_stubbed(:game, id: 57, created_at: 1.minute.ago, current_level: 7)])
      stub_template 'users/_game.html.erb' => 'User game goes here'
      render

      expect(rendered).to match('User game goes here')
    end
  end
end
