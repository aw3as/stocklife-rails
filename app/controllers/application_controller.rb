class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :verify_symbol

  def register
    puts params
  end

  private

  def verify_symbol
    puts params
  end


end
