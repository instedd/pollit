class Poll
  module RecurrenceStrategy
    extend ActiveSupport::Concern

    included do
      @@strategies = {
        none: NoneRecurrence,
        weekly: WeeklyRecurrence
      }

      def recurrence_strategy
        @@strategies[recurrence.kind].new(self)
      end
    end
  end

  class NoneRecurrence
    def initialize(poll)
      @poll = poll
    end

    def start
    end

    def pause
    end

    def resume
    end
  end

  class WeeklyRecurrence
    def initialize(poll)
      @poll = poll
    end

    def start
      @poll.recurrence.start_at = Time.now.utc
    end

    def pause
    end

    def resume
      @poll.recurrence.start_at = Time.now.utc
    end
  end
end
