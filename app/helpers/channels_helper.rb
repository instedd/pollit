module ChannelsHelper
  def back_to(step, options={})
    options.merge!(:remote => true)
    white_link_to 'Back', step_path(step), options
  end

  def back_to_start
    white_link_to 'Back', poll_new_channel_path(@poll)
  end
  
  def next_to(step, options={})
    options.merge!(:remote => true)
    grey_link_to 'Next', step_path(step), options
  end

  def step_path(step)
    poll_new_channel_path(@poll, step)
  end
end
