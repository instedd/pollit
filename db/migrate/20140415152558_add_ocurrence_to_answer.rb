class AddOcurrenceToAnswer < ActiveRecord::Migration
  def change
    add_column :answers, :occurrence, :datetime
  end
end
