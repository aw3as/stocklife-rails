class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  skip_before_filter  :verify_authenticity_token

  before_action :verify_symbol

  def register
    puts params[:text]
    puts "MESSAGE"
    render :nothing => true
  end

  def welcome
    render :text => 'Hello World'
  end

  private

  def verify_symbol
    if params[:text][0] != '!'
      render :nothing => true and return
    end
  end


end
