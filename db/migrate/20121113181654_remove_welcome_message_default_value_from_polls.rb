class RemoveWelcomeMessageDefaultValueFromPolls < ActiveRecord::Migration
  def up
    change_column :polls, :welcome_message, :string, :default => nil
  end

  def down
    change_column :polls, :welcome_message, :string, :default => "YES"
  end
end
