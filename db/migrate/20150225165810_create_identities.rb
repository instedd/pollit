class CreateIdentities < ActiveRecord::Migration
  def self.up
    create_table :identities do |t|
      t.integer :user_id
      t.string :provider
      t.string :token

      t.timestamps
    end
  end

  def self.down
    drop_table :identities
  end
end
