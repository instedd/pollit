class CreateRespondents < ActiveRecord::Migration
  def change
    create_table :respondents do |t|
      t.string :phone
      t.integer :poll_id

      t.timestamps
    end
  end
end
