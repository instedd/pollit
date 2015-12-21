module Telemetry::AccountsCountCollector
  def self.collect_stats(period)
    accounts = User.where('created_at < ?', period.end).count

    {
      counters: [
        {
          metric: 'accounts',
          key: {},
          value: accounts
        }
      ]
    }
  end
end
