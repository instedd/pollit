module Recurrences
  class Weekly < Base
    attr_accessor :start_at
    attr_accessor :days
    attr_accessor :interval

    def serialize
      {
        weekly: {
          start_at: start_at,
          days: days,
          interval: interval
        }
      }
    end

    def schedule
      Schedule.new(start_at).tap do |s|
        s.add_recurrence_rule(Rule.weekly(interval).day(*days))
      end
    end

    def next_date(from)
      schedule.next_occurrence(from)
    end
  end
end
