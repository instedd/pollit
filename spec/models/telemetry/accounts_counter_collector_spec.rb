require 'spec_helper'

describe Telemetry::AccountsCountCollector, telemetry: true do

  it 'counts applications' do
    User.make! created_at: to - 1.day
    User.make! created_at: to - 5.days
    User.make! created_at: from - 1.day
    User.make! created_at: to + 1.day

    stats = Telemetry::AccountsCountCollector.collect_stats period

    stats.should eq({
      counters: [{
        metric: 'accounts',
        key: {},
        value: 3
      }]
    })
  end

end
