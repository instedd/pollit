class AddCurrentQuestionSentToRespondents < ActiveRecord::Migration
  def change
    add_column :respondents, :current_question_sent, :boolean
  end
end
