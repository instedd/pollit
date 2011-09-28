class RemoveUserIdFromChannels < ActiveRecord::Migration
  def up
    remove_column :channels, :user_id
  end

  def down
    add_column :channels, :user_id, :integer
  end
end
