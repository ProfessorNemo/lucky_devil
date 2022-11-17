# https://stackoverflow.com/a/14061796/2237879
#
# This hack allows you to run make commands with any set of arguments.
#
# For example, these lines are the same:
#   > make g devise:install
#   > bundle exec rails generate devise:install
# And these:
#   > make migration add_deleted_at_to_users deleted_at:datetime
#   > bundle exec rails g migration add_deleted_at_to_users deleted_at:datetime
# And these:
#   > make model Order user:references record:references{polymorphic}
#   > bundle exec rails g model Order user:references record:references{polymorphic}
#
RUN_ARGS := $(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))

drop!:
	rails db:drop

initially:
	rails db:create
	rails db:migrate
	rails db:seed
	yarn install
	yarn build:css
	yarn build
	rails assets:precompile

migration:
	bundle exec rails g migration $(RUN_ARGS)

model:
	bundle exec rails g model $(RUN_ARGS)

create:
	bundle exec rails db:create

migrate:
	bundle exec rails db:migrate

rubocop:
	rubocop -A

web:
	ruby bin/rails server -p 3000

run-console:
	bundle exec rails console

rspec:
	bundle exec rspec spec/models/game_question_spec.rb
	bundle exec rspec spec/models/game_spec.rb
	bundle exec rspec spec/models/question_spec.rb
	bundle exec rspec spec/controllers/games_controller_spec.rb
	bundle exec rspec spec/views/users/index.html.erb_spec.rb
	bundle exec rspec spec/views/users/show.html.erb_spec.rb
	bundle exec rspec spec/views/users/_game.html.erb_spec.rb
	bundle exec rspec spec/views/games/_help.html.erb_spec.rb
	bundle exec rspec spec/views/games/_game_question.html.erb_spec.rb
	bundle exec rspec spec/features/user_creates_game_spec.rb
	bundle exec rspec spec/features/user_looks_another_user_page_spec.rb

c: run-console

.PHONY:	db
