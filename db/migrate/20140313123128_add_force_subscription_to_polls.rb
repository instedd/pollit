class AddForceSubscriptionToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :force_subscription, :boolean, default: false
  end
end
