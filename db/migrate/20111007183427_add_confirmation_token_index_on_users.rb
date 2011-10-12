class AddConfirmationTokenIndexOnUsers < ActiveRecord::Migration
  def up
    add_index :users, :confirmation_token, :unique => true
  end

  def down
    remove_index :users, :confirmation_token
  end
end
