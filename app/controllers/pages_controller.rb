class PagesController < ApplicationController
  def home
    # Redirect to assignments only if logged in and there is no flash message
    if logged_in? && flash.empty?
      redirect_to assignments_path
    end
  end
end
