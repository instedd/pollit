class AddLanguageToUser < ActiveRecord::Migration
  def change
    add_column :users, :lang, :string, :limit => 10
  end
end
