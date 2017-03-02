class AddCustomMessagesToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :custom_messages, :text
  end
end
