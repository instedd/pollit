module Telemetry::QuestionsByPollCollector
  def self.collect_stats(period)
    questions_by_poll = Question.where('created_at < ?', period.end).group(:poll_id).count

    counters = questions_by_poll.map do |poll_id, count|
      {
        metric: 'questions_by_poll',
        key: {poll_id: poll_id},
        value: count
      }
    end

    {counters: counters}
  end
end
