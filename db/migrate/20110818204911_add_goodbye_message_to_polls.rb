class AddGoodbyeMessageToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :goodbye_message, :string
  end
end
