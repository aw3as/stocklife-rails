class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  skip_before_filter  :verify_authenticity_token

  before_action :verify_symbol

  def receive
    if params[:attachments]
      pool = Pool.find_by(:group_id => params[:group_id])
      if pool
        user = User.find_by(:user_id => params[:user_id])
        if user
          participant = Participant.find_by(:user_id => user.id, :pool_id => pool.id)
          if participant
            other_user = User.find_by(:user_id => params[:attachments].first[:user_ids].first)
            if other_user
              other_participant = Participant.find_by(:user_id => other_user.id, :pool_id => pool.id)
              if other_participant
                amount = 0
                amount = amount + params[:message].split(' ')[-1].count('+')
                amount = amount - params[:message].split(' ')[-1].count('-')
                participant.transact(other_participant, amount)
              else
                Bot.message('Your recipient has not registered for $tocklife!')
              end
            else
              Bot.message('Your recipient has not registered in this pool!')
            end
          else
            Bot.message('You have not been registered in this pool!')
          end
        else
          Bot.message('You have not been registered for $tocklife!')
        end
      else
        Bot.message("$tocklife has not been started for this pool - @register to start one!")
      end
    else
      case params[:message]
      when 'register'
        pool = Pool.find_by(:group_id => params[:group_id])
        if pool
          user = User.find_by(:user_id => params[:user_id])
          if user
            if Participant.find_by(:user_id => user.id, :pool_id => pool.id)
              Bot.message("#{params[:name]} has already registered!")
            else
              User.register(pool, user)
            end
          else
            user = User.create(:user_id => params[:user_id], :name => params[:name])
            User.register(pool, user)
          end
        else
          pool = Pool.create(:group_id => params[:group_id])
          Bot.message("Initializing pool for the first time...")
          user = User.find_by(:user_id => params[:user_id])
          if user
              User.register(pool, user)
          else
            user = User.create(:user_id => params[:user_id], :name => params[:name])
            User.register(pool, user)
          end
        end
      when 'help'
        Bot.help
      when 'total'
        pool = Pool.find_by(:group_id => params[:group_id])
        if pool
          user = User.find_by(:user_id => params[:user_id])
          if user
            participant = Participant.find_by(:user_id => user.id, :pool_id => pool.id)
            if participant
              Bot.message("#{participant.user.name} has #{participant.total} points!")
            else
              Bot.message("You have not registered for $tocklife in this pool! Type '@register' to register")
            end
          else
            Bot.message("You have not registered for $tocklife! Type '@register' to register")
          end
        else
          Bot.message("$tocklife has not been started for this pool - @register to start one!")
        end
      when 'leaderboard'
        pool = Pool.find_by(:group_id => params[:group_id])
        if pool
          participants = pool.participants.sort_by(:total).reverse
          message = ''
          participants.each_with_index do |participant, index|
            message += "#{index + 1}. #{participant.user.name}: #{participant.total}\n"
          end
          Bot.message(message)
        else
          Bot.message("$tocklife has not been started for this pool - @register to start one!")
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
