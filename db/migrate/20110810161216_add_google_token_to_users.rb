class AddGoogleTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :google_token, :string
  end
end
