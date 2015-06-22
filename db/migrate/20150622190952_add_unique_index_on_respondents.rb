class AddUniqueIndexOnRespondents < ActiveRecord::Migration
  def change
    add_index :respondents, [:phone, :poll_id], unique: true
  end
end
