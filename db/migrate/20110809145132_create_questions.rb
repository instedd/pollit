class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :title
      t.string :description
      t.string :kind
      t.text :options

      t.timestamps
    end
  end
end
