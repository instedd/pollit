class TourController < ApplicationController
  def show
    render (params[:page] ||= 'start')
  end
end