module Telemetry::PollsByAccountCollector
  def self.collect_stats(period)
    period_end = ActiveRecord::Base.sanitize(period.end)

    results = ActiveRecord::Base.connection.execute <<-SQL
      SELECT users.id, COUNT(polls.owner_id)
      FROM users
      LEFT JOIN polls ON polls.owner_id = users.id
      AND polls.created_at < #{period_end}
      WHERE users.created_at < #{period_end}
      GROUP BY users.id
    SQL

    counters = results.map do |account_id, count|
      {
        metric: 'polls_by_account',
        key: {account_id: account_id},
        value: count
      }
    end

    {counters: counters}
  end
end
