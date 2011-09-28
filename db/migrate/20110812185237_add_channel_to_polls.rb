class AddChannelToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :channel, :string
  end
end
