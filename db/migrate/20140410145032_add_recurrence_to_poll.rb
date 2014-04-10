class AddRecurrenceToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :recurrence, :text
  end
end
