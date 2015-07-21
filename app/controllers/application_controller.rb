class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  skip_before_filter  :verify_authenticity_token

  before_action :verify_symbol

  def receive
    if params[:attachments]
      participant = Participant.find_by(:user_id => params[:user_id], :pool_id => Pool.find_by(:group_id => params[:group_id]).id)
      unless participant
        Bot.message("You have not registered for $tocklife! Type '@register' to register")
      else
        other_participant = Participant.find_by(:user_id => params[:attachments][:user_ids].first, :pool_id => participant.pool.id)
        unless other_participant
          Bot.message("Your recipient has not registered for $tocklife!")
        else
          amount = params[:message].split(' ')[-1].count('+')
          participant.transact(other_participant, amount)
        end
      end
    else
      puts 'MESSAGE'
      puts params[:message]
      case params[:message]
      when 'register'
        if Participant.find_by(:user_id => params[:user_id], :pool_id => Pool.find_by(:group_id => params[:group_id]).id)
          Bot.message("#{params[:name]} has already registered!")
        else
          User.register(params[:group_id], params[:user_id], params[:name])
        end
      when 'help'
        Bot.help
      when 'total'
        participant = Participant.find_by(:user_id => params[:user_id], :pool_id => Pool.find_by(:group_id => params[:group_id]).id)
        if participant
          Bot.message("#{participant.user.name} has #{participant.total} points!")
        else
          Bot.message("You have not registered for $tocklife! Type '@register' to register")
        end
      end
    end
    
    render :nothing => true
  end

  def welcome
    render :text => 'Hello World'
  end

  private

  def verify_symbol
    if params[:text][0] != '@' or params[:sender_type] == 'bot'
      render :nothing => true and return
    end
    params[:message] = params[:text][1..-1]
  end


end
