class CreatePolls < ActiveRecord::Migration
  def change
    create_table :polls do |t|
      t.string :title
      t.string :description
      t.integer :owner
      t.string :url

      t.timestamps
    end
  end
end
