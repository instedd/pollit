class AddChannelIdToRespondents < ActiveRecord::Migration
  def change
    add_column :respondents, :channel_id, :integer
  end
end
