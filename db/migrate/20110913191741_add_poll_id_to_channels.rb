class AddPollIdToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :poll_id, :integer
  end
end
