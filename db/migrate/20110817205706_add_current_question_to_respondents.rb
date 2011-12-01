class AddCurrentQuestionToRespondents < ActiveRecord::Migration
  def change
    add_column :respondents, :current_question_id, :integer
  end
end
