class LocaleController < ApplicationController

  def update    
    url = Rails.application.routes.recognize_path(request.referer)
    url[:locale] = session[:locale] = params[:requested_locale]
    redirect_to url
  end

end