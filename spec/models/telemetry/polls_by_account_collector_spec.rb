require 'spec_helper'

describe Telemetry::PollsByAccountCollector, telemetry: true do

  it 'counts polls by account' do
    user_1 = User.make! created_at: to - 150.days
    user_2 = User.make! created_at: to - 37.days
    user_3 = User.make! created_at: to + 1.day

    Poll.make! owner: user_1, created_at: to - 1.day
    Poll.make! owner: user_1, created_at: to - 5.days
    Poll.make! owner: user_1, created_at: to - 100.days
    Poll.make! owner: user_1, created_at: to + 7.days

    Poll.make! owner: user_2, created_at: to - 7.day
    Poll.make! owner: user_2, created_at: to - 30.days

    Poll.make! owner: user_3, created_at: to + 1.day

    stats = Telemetry::PollsByAccountCollector.collect_stats period
    counters = stats[:counters]

    counters.size.should eq(2)

    counters.should include({
      metric: 'polls_by_account',
      key: {account_id: user_1.id},
      value: 3
    })

    counters.should include({
      metric: 'polls_by_account',
      key: {account_id: user_2.id},
      value: 2
    })
  end

  it 'counts accounts with 0 polls' do
    user_1 = User.make! created_at: to - 5.days
    user_2 = User.make! created_at: to - 1.day
    user_3 = User.make! created_at: to + 1.day

    Poll.make! owner: user_2, created_at: to + 1.day
    Poll.make! owner: user_3, created_at: to + 3.days

    stats = Telemetry::PollsByAccountCollector.collect_stats period
    counters = stats[:counters]

    counters.size.should eq(2)

    counters.should include({
      metric: 'polls_by_account',
      key: {account_id: user_1.id},
      value: 0
    })

    counters.should include({
      metric: 'polls_by_account',
      key: {account_id: user_2.id},
      value: 0
    })
  end

end
