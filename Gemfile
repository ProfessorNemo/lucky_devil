# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.3'

gem 'jbuilder', '~> 2.7'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'
gem 'rails', '~> 6.1.6', '>= 6.1.6.1'
gem 'sass-rails', '>= 6'
gem 'turbolinks', '~> 5'
gem 'webpacker', '~> 5.0'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Удобная админка для управления любыми сущностями
gem 'rails_admin'

gem 'devise', '~> 4.8'
gem 'devise-i18n'

gem 'font-awesome-rails'
gem 'jquery-rails'
gem 'russian'
gem 'twitter-bootstrap-rails'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

group :development, :test do
  gem 'byebug'
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'
  gem 'rspec-rails', '>= 5.1.2'
  gem 'shoulda-matchers'
  # Гем, который использует rspec, чтобы смотреть наш сайт
  gem 'capybara'
  # Гем, который позволяет смотреть, что видит capybara
  gem 'launchy'
end

group :development do
  gem 'listen', '~> 3.3'
  gem 'rack-mini-profiler', '~> 3.0'
  gem 'rubocop', '~> 1.30', require: false
  gem 'rubocop-performance', '~> 1.14', require: false
  gem 'rubocop-rails', '~> 2.14', require: false
  gem 'rubocop-rspec', require: false
  gem 'spring'
  gem 'web-console', '>= 4.1.0'
end

# Gemfile (очистить базу данных)
# https://github.com/DatabaseCleaner/database_cleaner
group :test do
  gem 'database_cleaner-active_record'
end
