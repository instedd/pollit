module Telemetry::QuestionsByPollCollector
  def self.collect_stats(period)
    period_end = ActiveRecord::Base.sanitize(period.end)

    results = ActiveRecord::Base.connection.execute <<-SQL
      SELECT polls.id, COUNT(questions.poll_id)
      FROM polls
      LEFT JOIN questions ON questions.poll_id = polls.id
      AND questions.created_at < #{period_end}
      WHERE polls.created_at < #{period_end}
      GROUP BY polls.id
    SQL

    counters = results.map do |poll_id, count|
      {
        metric: 'questions_by_poll',
        key: {poll_id: poll_id},
        value: count
      }
    end

    {counters: counters}
  end
end
