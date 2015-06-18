class AddMustContainToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :must_contain, :string
  end
end
