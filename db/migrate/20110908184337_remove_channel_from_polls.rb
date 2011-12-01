class RemoveChannelFromPolls < ActiveRecord::Migration
  def up
    remove_column :polls, :channel
  end

  def down
    add_column :polls, :channel, :string
  end
end
