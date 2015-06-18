class AddNextQuestionToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :next_question_definition, :text
  end
end
