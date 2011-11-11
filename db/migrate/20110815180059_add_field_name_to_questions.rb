class AddFieldNameToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :field_name, :string
  end
end
