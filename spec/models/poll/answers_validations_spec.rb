require 'spec_helper'

describe Poll do

  context "answers validations" do

    let(:poll)       { Poll.make!(kind: 'manual', questions: [question], respondents: [Respondent.make]) }
    let(:respondent) { poll.respondents.first }

    before(:each) do
      poll.stubs(:send_messages).returns(true)
      poll.start
      poll.accept_answer(poll.confirmation_words.first, respondent)
    end

    def accepts_answer(answer)
      poll.accept_answer(answer, respondent).should eq(poll.goodbye_message)
      respondent.current_question_id.should be_nil
    end

    def rejects_answer(answer, error=nil)
      reply = poll.accept_answer(answer, respondent)
      reply.should =~ /\AYour answer was not understood/
      reply.should include(error) if error
      respondent.current_question_id.should eq(poll.questions.first.id)
    end

    context "numeric question" do

      context "with min and max" do
        let(:question) { Question.make(kind: 'numeric', numeric_min: 10, numeric_max: 20) }

        it { accepts_answer("15") }
        it { accepts_answer("10") }
        it { accepts_answer("20") }

        it { rejects_answer("8") }
        it { rejects_answer("32") }
        it { rejects_answer("-10") }
        it { rejects_answer("not a number") }
      end

      context "with min" do
        let(:question) { Question.make(kind: 'numeric', numeric_min: 10) }

        it { accepts_answer("15") }
        it { accepts_answer("10") }
        it { accepts_answer("50") }

        it { rejects_answer("8") }
        it { rejects_answer("-10") }
        it { rejects_answer("not a number") }
      end

      context "with max" do
        let(:question) { Question.make(kind: 'numeric', numeric_max: 20) }

        it { accepts_answer("15")  }
        it { accepts_answer("20")  }
        it { accepts_answer("-10") }
        it { accepts_answer("0")   }

        it { rejects_answer("50") }

        it { rejects_answer("not a number") }
      end

      context "without range" do
        let(:question) { Question.make(kind: 'numeric') }

        it { accepts_answer("15")  }
        it { accepts_answer("20")  }
        it { accepts_answer("-10") }
        it { accepts_answer("0")   }

        it { rejects_answer("not a number") }
      end

    end

    context "text question" do

      context "with min and max length" do
        let(:question) { Question.make(kind: 'text', min_length: 3, max_length: 6) }

        it { accepts_answer("foo") }
        it { accepts_answer("foobar") }
        it { accepts_answer("fooz") }
        it { accepts_answer("1234") }
        it { accepts_answer("   fooz   ") }

        it { rejects_answer("fo") }
        it { rejects_answer("foobarb") }
        it { rejects_answer("") }
        it { rejects_answer("     ") }
      end

      context "with min length" do
        let(:question) { Question.make(kind: 'text', min_length: 3) }

        it { accepts_answer("foo") }
        it { accepts_answer("foobar") }
        it { accepts_answer("fooz") }
        it { accepts_answer("1234") }

        it { rejects_answer("fo") }
        it { rejects_answer("") }
        it { rejects_answer("     ") }
      end

      context "with max length" do
        let(:question) { Question.make(kind: 'text', max_length: 6) }

        it { accepts_answer("foo") }
        it { accepts_answer("foobar") }

        it { rejects_answer("foobarb") }
        it { rejects_answer("") }
        it { rejects_answer("     ") }
      end

      context "with contains" do
        let(:question) { Question.make(kind: 'text', must_contain: 'foo') }

        it { accepts_answer("   foo   ")  }
        it { accepts_answer("barfoobaz")  }
        it { accepts_answer("foo") }
        it { accepts_answer("FOO") }

        it { rejects_answer("") }
        it { rejects_answer("     ") }
        it { rejects_answer("bar") }
      end

      context "with contains in caps" do
        let(:question) { Question.make(kind: 'text', must_contain: 'FOO') }

        it { accepts_answer("   foo   ")  }
        it { accepts_answer("barfoobaz")  }
        it { accepts_answer("foo") }
        it { accepts_answer("FOO") }

        it { rejects_answer("") }
        it { rejects_answer("     ") }
        it { rejects_answer("bar") }
      end

      context "without validation" do
        let(:question) { Question.make(kind: 'text') }

        it { accepts_answer("foo")  }

        it { rejects_answer("") }
        it { rejects_answer("     ") }
      end

    end

  end

end
