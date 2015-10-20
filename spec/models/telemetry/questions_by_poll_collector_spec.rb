require 'spec_helper'

describe Telemetry::QuestionsByPollCollector, telemetry: true do

  it 'counts polls by account' do
    poll_1 = Poll.make!
    poll_2 = Poll.make!

    Question.make! poll: poll_1, created_at: to - 1.day
    Question.make! poll: poll_1, created_at: to - 10.days
    Question.make! poll: poll_1, created_at: to - 10.days
    Question.make! poll: poll_1, created_at: to - 12.days

    Question.make! poll: poll_2, created_at: to - 1.day
    Question.make! poll: poll_2, created_at: to - 30.days
    Question.make! poll: poll_2, created_at: to + 1.day

    stats = Telemetry::QuestionsByPollCollector.collect_stats period
    counters = stats[:counters]

    counters.size.should eq(2)

    counters.should include({
      metric: 'questions_by_poll',
      key: {poll_id: poll_1.id},
      value: 4
    })

    counters.should include({
      metric: 'questions_by_poll',
      key: {poll_id: poll_2.id},
      value: 2
    })
  end

end
