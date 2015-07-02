class BaseAnswersListing < Listings::Base
  model do
    @poll = Poll.where(owner_id: current_user.id).find(params[:poll_id])
    # TODO
    # current_user.authorize! :manage, poll
    # without owner_id filter

    Answer.includes(:respondent).where(respondents: {poll_id: @poll.id})
  end

  def no_data_message
    if @poll.status_configuring?
      _("This poll has not commenced yet; start the poll to receive answers from your respondents.")
    else
      _("No answers have been received yet.")
    end
  end
end
