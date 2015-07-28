class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  skip_before_filter  :verify_authenticity_token

  before_action :verify_symbol, :except => [:pool, :register]

  def receive
    pool = Pool.find_by(:group_id => params[:group_id])
    if params[:attachments]
      user = User.find_by(:user_id => params[:user_id])
      if user
        participant = Participant.find_by(:user_id => user.id, :pool_id => pool.id)
        if participant
          other_user = User.find_by(:user_id => params[:attachments].first[:user_ids].first)
          if other_user
            other_participant = Participant.find_by(:user_id => other_user.id, :pool_id => pool.id)
            if other_participant
              amount = 0
              amount = amount + params[:message].gsub(other_participant.user.name, '').count('+')
              amount = amount - params[:message].gsub(other_participant.user.name, '').count('-')
              participant.transact(other_participant, amount)
            else
              Bot.message(pool, 'Your recipient has not registered for $tocklife!')
            end
          else
            Bot.message(pool, 'Your recipient has not registered in this pool!')
          end
        else
          Bot.message(pool, 'You have not been registered in this pool!')
        end
      else
        Bot.message(pool, 'You have not been registered for $tocklife!')
      end
    else
      case params[:message]
      when 'register'
        user = User.find_by(:user_id => params[:user_id])
        if user
          if Participant.find_by(:user_id => user.id, :pool_id => pool.id)
            Bot.message(pool, "#{params[:name]} has already registered!")
          else
            User.register(pool, user)
          end
        else
          user = User.create(:user_id => params[:user_id], :name => params[:name])
          User.register(pool, user)
        end
      when 'help'
        Bot.help(pool)
      when 'commands'
        Bot.command(pool)
      when 'total'
        user = User.find_by(:user_id => params[:user_id])
        if user
          participant = Participant.find_by(:user_id => user.id, :pool_id => pool.id)
          if participant
            Bot.message(pool, "#{participant.user.name} has #{participant.total} points!")
          else
            Bot.message(pool, "You have not registered for $tocklife in this pool! Type '@register' to register")
          end
        else
          Bot.message(pool, "You have not registered for $tocklife! Type '@register' to register")
        end
      when 'leaderboard'
        participants = pool.participants.sort_by(&:total).reverse
        message = ''
        participants.each_with_index do |participant, index|
          message += "#{index + 1}. #{participant.user.name}: $#{participant.total}\n"
        end
        Bot.message(pool, message)
      when 'admin'
        Bot.message(pool, "#{pool.admin.user.name} is the admin!")
      when 'reset'
        user = User.find_by(:user_id => params[:user_id])
        if pool.admin.user == user
          pool.wipe
          Bot.message(pool, "The pool has been reset!")
        else
          Bot.message(pool, "You're not the admin!")
        end
      when 'status'
        Bot.status(pool)
      end
    end
    
    render :nothing => true
  end

  def register
    pool = Pool.create(:group_id => params[:group_id], :bot_id => params[:bot_id])
    Bot.message(pool, "$tocklife has been initialized for this pool! Type @help for commands, and @register to begin playing!")
    render :json => {:success => true}
  end

  def pool
    render 'ui/index'
  end

  private

  def verify_symbol
    if params[:text][0] != '@' or params[:sender_type] == 'bot'
      render :nothing => true and return
    end
    params[:message] = params[:text][1..-1]
  end


end
