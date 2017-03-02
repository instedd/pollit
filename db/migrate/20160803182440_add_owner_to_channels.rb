class AddOwnerToChannels < ActiveRecord::Migration
  class Channel <ActiveRecord::Base
    belongs_to :poll
    belongs_to :owner, class_name: 'User'
  end

  class Poll < ActiveRecord::Base
    belongs_to :owner, class_name: 'User'
  end

  def up
    add_column :channels, :owner_id, :integer

    Channel.includes(:poll).find_each do |channel|
      channel.owner = channel.poll.owner
      channel.save!
    end
  end

  def down
    remove_column :channels, :owner_id
  end
end
