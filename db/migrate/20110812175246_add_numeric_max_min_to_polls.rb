class AddNumericMaxMinToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :numeric_max, :int
    add_column :polls, :numeric_min, :int
  end
end
