class AddLengthToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :min_length, :integer, nullable: true
    add_column :questions, :max_length, :integer, nullable: true
  end
end
