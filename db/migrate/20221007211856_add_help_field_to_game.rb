# frozen_string_literal: true

class AddHelpFieldToGame < ActiveRecord::Migration[6.1]
  def change
    add_column :games, :fifty_fifty_used, :boolean, default: false, null: false
    add_column :games, :audience_help_used, :boolean, default: false, null: false
    add_column :games, :friend_call_used, :boolean, default: false, null: false
    add_column :games, :replacement_question_used, :boolean, default: false, null: false
  end
end
