class Poll
  module RecurrenceStrategy
    extend ActiveSupport::Concern

    included do
      def recurrence_strategy
        if recurrence.recurrence_rules.empty?
          NoneRecurrence.new(self)
        else
          IterativeRecurrence.new(self)
        end
      end

      def recurrence_kind
        recurrence_strategy.recurrence_kind
      end
    end
  end

  class NoneRecurrence
    def initialize(poll)
      @poll = poll
    end

    def recurrence_kind
      :none
    end

    def start
    end

    def pause
    end

    def resume
    end
  end

  class IterativeRecurrence
    def initialize(poll)
      @poll = poll
    end

    def recurrence_kind
      :iterative
    end

    def start
      @poll.recurrence_start_time = Time.now.utc
    end

    def pause
    end

    def resume
      @poll.recurrence_start_time = Time.now.utc
    end
  end
end
