require 'spec_helper'

describe Telemetry::NumbersByCountryCodeCollector, telemetry: true do

  it 'counts numbers by country code' do
    poll_1 = Poll.make!
    poll_2 = Poll.make!

    # count only 1
    Respondent.make! phone: 'sms://541144445555', poll: poll_1, created_at: to - 1.day
    Respondent.make! phone: 'sms://541144445555', poll: poll_2, created_at: to - 10.days

    # don't count since is beyond period
    Respondent.make! phone: 'sms://541166667777', poll: poll_1, created_at: to + 1.day

    # count 3
    Respondent.make! phone: 'sms://85523217391', poll: poll_1, created_at: to - 7.days
    Respondent.make! phone: 'sms://85563337444', poll: poll_2, created_at: to - 30.days
    Respondent.make! phone: 'sms://85511111111', poll: poll_2, created_at: to - 15.days

    stats = Telemetry::NumbersByCountryCodeCollector.collect_stats period
    counters = stats[:counters]

    counters.size.should eq(6)

    counters.should include({
      metric: 'unique_phone_numbers_by_country',
      key: {country_code: '54'},
      value: 1
    })

    counters.should include({
      metric: 'unique_phone_numbers_by_country',
      key: {country_code: '855'},
      value: 3
    })

    counters.should include({
      metric: 'unique_phone_numbers_by_project_and_country',
      key: {country_code: '54', project_id: poll_1.id},
      value: 1
    })

    counters.should include({
      metric: 'unique_phone_numbers_by_project_and_country',
      key: {country_code: '855', project_id: poll_1.id},
      value: 1
    })

    counters.should include({
      metric: 'unique_phone_numbers_by_project_and_country',
      key: {country_code: '54', project_id: poll_2.id},
      value: 1
    })

    counters.should include({
      metric: 'unique_phone_numbers_by_project_and_country',
      key: {country_code: '855', project_id: poll_2.id},
      value: 2
    })
  end
end
