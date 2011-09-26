class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.integer :user_id
      t.string :name
      t.string :address

      t.timestamps
    end
  end
end
