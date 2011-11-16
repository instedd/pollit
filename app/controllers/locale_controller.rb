class LocaleController < ApplicationController

  def update
    session[:locale] = params[:requested_locale]
    redirect_to request.referer
  end

end