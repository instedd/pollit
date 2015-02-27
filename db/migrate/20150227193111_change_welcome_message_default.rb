class ChangeWelcomeMessageDefault < ActiveRecord::Migration
  def up
    change_column :polls, :welcome_message, :string, :default => "Welcome"
  end

  def down
    change_column :polls, :welcome_message, :string, :default => "YES"
  end
end
