class ChangePollIdToQuestionIdForAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :question_id, :integer
    remove_column :answers, :poll_id
  end
end
