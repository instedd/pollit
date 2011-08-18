class RenameOwnerFieldInPolls < ActiveRecord::Migration
  def up
    rename_column :polls, :owner, :owner_id
  end

  def down
    rename_column :polls, :owner_id, :owner
  end
end
