class TopController < ApplicationController
  def index
    if user_signed_in?
      flash.keep
      redirect_to '/topics'
    end
  end
end
