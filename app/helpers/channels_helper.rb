module ChannelsHelper
  def back_to(step, options={})
    options.merge!(:remote => true)
    white_link_to 'Back', step_path(step), options
  end

  def next_to(step, options={})
    options.merge!(:remote => true)
    grey_link_to 'Next', step_path(step), options
  end

  def back_to_start
    if params[:wizard]
      white_link_to 'Back', edit_poll_path(@poll)
    else
      white_link_to 'Back', step_path
    end
  end

  def step_path(step=nil)
    if params[:wizard]
      poll_new_channel_path(@poll, step, :wizard => 1)
    else
      poll_new_channel_path(@poll, step)
    end
  end
end
