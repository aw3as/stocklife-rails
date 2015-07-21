class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  skip_before_filter  :verify_authenticity_token

  before_action :verify_symbol

  def receive
    if params[:message] = 'register'
      pool = Pool.find_by(:group_id => params[:group_id])
      unless pool
        pool = Pool.create(:group_id => params[:group_id])
      end
      user = User.find_by(:user_id => params[:user_id])
      unless user
        user = User.create(:user_id => params[:user_id], :name => params[:name])
      end
      participant = Participant.create(:user_id => user.id, :pool_id => pool.id)
    end
    message("#{user.name} has succesfully registered!")
    render :nothing => true
  end

  def welcome
    render :text => 'Hello World'
  end

  def message(message)
    id = 'fab0cad741b6d1a7f1b02e19e8'
    Curl.post("https://api.groupme.com/v3/bots/post?bot_id=#{id}&text=#{CGI.escape(message)}")
  end

  private

  def verify_symbol
    if params[:text][0] != '@' or params[:sender_type] == 'bot'
      render :nothing => true and return
    end
    params[:message] = params[:text][1..-1]
  end


end
