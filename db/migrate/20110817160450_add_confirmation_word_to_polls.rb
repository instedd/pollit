class AddConfirmationWordToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :confirmation_word, :string
  end
end
