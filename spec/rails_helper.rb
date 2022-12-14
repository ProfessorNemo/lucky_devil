# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!

  # Подключаем девайзовые классы для использвоания в тестах
  # https://github.com/plataformatec/devise#test-helpers
  # https://github.com/plataformatec/devise/issues/4133

  # В тестах на контроллеры и представления подключаем специальные
  # хелперы для авторизации с помощью девайс (дает такой метод, как "login_as")
  config.include Devise::TestHelpers, type: :controller
  config.include Devise::TestHelpers, type: :view

  # Подключаем в фичах специальные хелперы для авторизации пользователя в features:
  config.include Warden::Test::Helpers, type: :feature
end

# специальные "матчеры" - методы, удобные для тестирования валидаций
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

# Это нужно, чтобы капибара искала стили и js в правильном месте
Capybara.asset_host = 'http://localhost:3000'
