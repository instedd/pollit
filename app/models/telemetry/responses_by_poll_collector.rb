module Telemetry::ResponsesByPollCollector
  def self.collect_stats(period)
    period_end = ActiveRecord::Base.sanitize(period.end)

    results = ActiveRecord::Base.connection.execute <<-SQL
      SELECT polls.id, COUNT(answers.question_id)
      FROM polls
      LEFT JOIN questions ON questions.poll_id = polls.id
      LEFT JOIN answers ON answers.question_id = questions.id
      AND answers.created_at < #{period_end}
      WHERE polls.created_at < #{period_end}
      GROUP BY polls.id
    SQL

    counters = results.map do |poll_id, count|
      {
        metric: 'responses_by_poll',
        key: {poll_id: poll_id},
        value: count
      }
    end

    {counters: counters}
  end
end
