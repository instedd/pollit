class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.integer :poll_id
      t.integer :respondent_id
      t.string :response
      t.integer :response_id

      t.timestamps
    end
  end
end
