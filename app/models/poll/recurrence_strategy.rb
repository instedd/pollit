class Poll
  module RecurrenceStrategy
    extend ActiveSupport::Concern

    included do
      after_save do
        if self.status != :started
          self.remove_existing_jobs
        end
      end

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

      def iterate(ocurrence)
        recurrence_strategy.iterate(ocurrence)
      end

      def remove_existing_jobs
        Delayed::Job.where(:poll_id => self.id).delete_all
      end

      def append_answer_attributes(attributes)
        recurrence_strategy.append_answer_attributes(attributes)
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
      @poll.invite_all_respondents
    end

    def pause
    end

    def resume
      messages = []

      # Invite respondents that were added while the poll was paused
      @poll.invite_new_respondents

      # Sends next questions to users with a current question and without the current_question_sent mark
      respondents_to_send_next_question = @poll.respondents.where(:current_question_sent => false).where('current_question_id IS NOT NULL')
      respondents_to_send_next_question.each do |r|
        messages << @poll.message_to(r, r.current_question.message)
      end

      # Must send goodbye to confirmed users without current question (finished poll) but already confirmed (to avoid sending to those unconfirmed)
      respondents_to_goodbye = @poll.respondents.where(:current_question_sent => false).where(:confirmed => true).where('current_question_id IS NULL')
      respondents_to_goodbye.each do |r|
        messages << @poll.message_to(r, @poll.goodbye_message)
      end

      @poll.send_messages messages

      [respondents_to_send_next_question, respondents_to_goodbye].each do |rs|
        rs.update_all :current_question_sent => true
      end
    end

    def iterate(ocurrence)
    end

    def append_answer_attributes(attributes)
      attributes[:occurrence] = nil
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
      schedule_next
    end

    def pause
    end

    def resume
      @poll.recurrence_start_time = Time.now.utc
      schedule_next
    end

    def iterate(ocurrence)
      @poll.current_occurrence = ocurrence
      schedule_next

      @poll.invite_new_respondents

      messages = []

      send_first_question = @poll.respondents.where(:confirmed => true)
      send_first_question.each do |r|
        # reset all confirmed respondents to the begining of the form
        messages << @poll.message_to(r, @poll.initialize_respondent(r))
      end

      @poll.send_messages messages
      @poll.save
    end

    def schedule_next
      # TODO how to ensure recurrence is not changed while the poll is running?
      @poll.remove_existing_jobs
      next_occurrence = @poll.recurrence.next_occurrence(@poll.current_occurrence)
      Delayed::Job.enqueue IteratePoll.new(@poll.id, next_occurrence),
        poll_id: @poll.id,
        run_at: next_occurrence
    end

    def append_answer_attributes(attributes)
      attributes[:occurrence] = @poll.current_occurrence
    end
  end
end
