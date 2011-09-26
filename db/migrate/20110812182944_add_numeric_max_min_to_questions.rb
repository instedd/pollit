class AddNumericMaxMinToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :numeric_max, :int
    add_column :questions, :numeric_min, :int

    remove_column :polls, :numeric_max
    remove_column :polls, :numeric_min
  end
end
