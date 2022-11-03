# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.3'

gem 'cssbundling-rails', '~> 1.0'
gem 'devise', '~> 4.8'
gem 'font-awesome-rails', '~> 4.7'
gem 'jsbundling-rails', '~> 1.0'
gem 'pg', '~> 1.1'
gem 'puma', '~> 6.0'
gem 'rails', '~> 6.1.6', '>= 6.1.6.1'
gem 'sassc-rails'
gem 'sprockets-rails', '~> 3.4'
gem 'turbolinks', '~> 5'
gem 'twitter-bootstrap-rails'

gem 'devise-i18n'
# админка для управления любыми сущностями
gem 'letter_opener'
gem 'rails_admin'
gem 'rails_admin-i18n'
gem 'rails-i18n'
gem 'valid_email2', '~> 4.0'

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
  gem 'web-console', '>= 4.1.0'
end

# очистить базу данных
# https://github.com/DatabaseCleaner/database_cleaner
group :test do
  gem 'database_cleaner-active_record'
end
