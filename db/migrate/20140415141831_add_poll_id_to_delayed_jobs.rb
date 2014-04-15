class AddPollIdToDelayedJobs < ActiveRecord::Migration
  def change
    add_column :delayed_jobs, :poll_id, :integer
  end
end
