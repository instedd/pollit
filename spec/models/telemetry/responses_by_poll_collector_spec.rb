require 'spec_helper'

describe Telemetry::ResponsesByPollCollector, telemetry: true do

  it 'counts responses by poll' do
    poll_1 = Poll.make!
    poll_2 = Poll.make!

    question_1_1 = Question.make! poll: poll_1

    question_2_1 = Question.make! poll: poll_2
    question_2_2 = Question.make! poll: poll_2

    Answer.make! question: question_1_1, created_at: to - 1.day
    Answer.make! question: question_1_1, created_at: to - 10.days
    Answer.make! question: question_1_1, created_at: to + 1.day

    Answer.make! question: question_2_1, created_at: to - 5.days
    Answer.make! question: question_2_1, created_at: to - 7.days
    Answer.make! question: question_2_1, created_at: to + 2.days

    Answer.make! question: question_2_2, created_at: to - 3.days
    Answer.make! question: question_2_2, created_at: to - 30.days
    Answer.make! question: question_2_2, created_at: to - 100.days
    Answer.make! question: question_2_2, created_at: to - 300.days

    stats = Telemetry::ResponsesByPollCollector.collect_stats period
    counters = stats[:counters]

    counters.size.should eq(2)

    counters.should include({
      metric: 'responses_by_poll',
      key: {poll_id: poll_1.id},
      value: 2
    })

    counters.should include({
      metric: 'responses_by_poll',
      key: {poll_id: poll_2.id},
      value: 6
    })
  end

end
