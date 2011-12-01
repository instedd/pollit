class AddWelcomeMessageToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :welcome_message, :string, :default => "YES"
  end
end
