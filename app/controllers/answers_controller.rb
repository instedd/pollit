class AnswersController < ApplicationController

  add_breadcrumb "Polls", :polls_path
  
  before_filter :load_poll

  def index
    add_breadcrumb "Answers", poll_answers_path(@poll)
  end

end
