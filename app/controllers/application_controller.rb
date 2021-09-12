# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  protected
  def authenticate_user!
    if user_signed_in?
      super
    else
      redirect_to root_path, :notice => 'Please log in to continue.'
    end
  end
end
