class AddCollectsRespondentToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :collects_respondent, :boolean, default: false
  end
end
