class IteratePoll < Struct.new(:poll_id, :ocurrence)
  # https://github.com/collectiveidea/delayed_job/pull/355
  Delayed::Backend::ActiveRecord::Job.send(:attr_accessible, :poll_id)

  def perform
    poll = Poll.find(poll_id)
    poll.iterate(ocurrence)
  end
end
