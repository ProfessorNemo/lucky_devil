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

webpacker:
	./bin/webpack-dev-server

run-console:
	bundle exec rails console

rspec:
	bundle exec rspec spec/models/game_spec.rb
	bundle exec rspec spec/controllers/games_controller_spec.rb

c: run-console

.PHONY:	db