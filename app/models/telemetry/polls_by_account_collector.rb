module Telemetry::PollsByAccountCollector
  def self.collect_stats(period)
    polls_by_account = Poll.where('created_at < ?', period.end).group(:owner_id).count

    counters = polls_by_account.map do |account_id, count|
      {
        metric: 'polls_by_account',
        key: {account_id: account_id},
        value: count
      }
    end

    {counters: counters}
  end
end
