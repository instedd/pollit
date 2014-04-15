class AddCurrentOcurrenceToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :current_occurrence, :datetime
  end
end
