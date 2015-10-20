module Telemetry::ResponsesByPollCollector
  def self.collect_stats(period)
    responses_by_poll = Answer.joins(:question).where('answers.created_at < ?', period.end).group('questions.poll_id').count

    counters = responses_by_poll.map do |poll_id, count|
      {
        metric: 'responses_by_poll',
        key: {poll_id: poll_id},
        value: count
      }
    end

    {counters: counters}
  end
end
