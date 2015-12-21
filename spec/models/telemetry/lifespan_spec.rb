require 'spec_helper'

describe Telemetry::Lifespan, telemetry: true do

  it 'updates the account lifespan' do
    now = Time.now
    from = now - 1.week

    Time.stub(:now).and_return(now)

    user = User.make! created_at: from

    InsteddTelemetry.should_receive(:timespan_update) do |metric, key, from, to|
      metric.should eq('account_lifespan')
      key.should eq({account_id: user.id})
      from.should eq(user.reload.created_at)
      to.should eq(now)
    end

    Telemetry::Lifespan.touch_user user
  end

end
