class ChannelsController < ApplicationController
  add_breadcrumb _("Polls"), :polls_path

  before_filter :authenticate_user!
  before_filter :load_poll

  def show
    redirect_to :action => 'new', :wizard => params[:wizard] and return unless @poll.channel
    @channel = @poll.channel
    render :layout => 'wizard' if params[:wizard]
  end

  def new
    set_current_step(params[:step] || "a_choose_local_gateway")
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @poll.channel.destroy if @poll.channel
    @channel = @poll.register_channel(params[:channel][:ticket_code])

    if @channel.valid?
      if params[:wizard]
        redirect_to poll_respondents_path(@poll, :wizard => true)
      elsif request.xhr?
        set_current_step("d_end_wizard")
        render 'new'
      else
        redirect_to new_poll_channel_path(@poll, "d_end_wizard")
      end
    else
      set_current_step(params[:next_step])
      render "new"
    end
  end

  def destroy
    Channel.find(params[:id]).destroy
    redirect_to new_poll_channel_path(@poll)
  end

  protected

  def set_steps
    if params[:action].to_sym == :show
      @wizard_step = _("Channel")
      return super
    end

    @steps = [_("Choose"), _("Install"), _("Connect"), _("Finish")]
    @dotted_steps = [_("Properties"), _("Choose"), _("Install"), _("Connect"), _("Respondents")]
    @wizard_step = _('Choose')
  end

  private

  def set_current_step(step)
    @step = step
    {"a" => _("Choose"), "b" => _("Install"), "c" => _("Connect"), "d" => _("Finish")}.each_pair do |k,v|
      @wizard_step = v if @step.start_with?(k)
    end
  end
end