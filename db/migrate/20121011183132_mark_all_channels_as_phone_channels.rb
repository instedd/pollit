class MarkAllChannelsAsPhoneChannels < ActiveRecord::Migration
  def up
    execute "update channels set type = 'PhoneChannel'"
  end

  def down
    execute "update channels set type = null"
  end
end
