class AddWelcomeMessageToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :welcome_message, :string
  end
end
