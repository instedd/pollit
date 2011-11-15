module ChannelsHelper
  def back_to(step, options={})
    options.merge!(:remote => true)
    white_link_to _('Back'), step_path(step), options
  end

  def next_to(step, options={})
    options.merge!(:remote => true)
    grey_link_to _('Next'), step_path(step), options
  end

  def back_to_start
    if params[:wizard]
      white_link_to _('Back'), edit_poll_path(@poll, :wizard => true)
    else
      white_link_to _('Back'), step_path
    end
  end

  def step_path(step=nil)
    new_poll_channel_path(@poll, :step => step, :wizard => params[:wizard])
  end
end
