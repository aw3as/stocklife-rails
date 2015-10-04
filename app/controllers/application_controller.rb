class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  skip_before_filter  :verify_authenticity_token

  before_action :verify_symbol, :except => [:pool, :register]

  def receive
    pool = Pool.find_by(:group_id => params[:group_id])
    if params[:attachments]
      if pool.started
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
        Bot.message(pool, "The pool has not been started yet! Message #{pool.admin.user.name} to start the pool!")
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
      when 'prices'
        Bot.message(pool, pool.prices)
      when 'price'
        Bot.message(pool, pool.prices)
      when 'leaderboard'
        Bot.message(pool, pool.leaderboard)
      when 'admin'
        Bot.message(pool, "#{pool.admin.user.name} is the admin!")
      when 'start'
        user = User.find_by(:user_id => params[:user_id])
        if user
          participant = Participant.find_by(:user_id => user.id, :pool_id => pool.id)
          if participant
            if participant == pool.admin
              if pool.started
                Bot.message(pool, "$tocklife has already been started for this pool!")
              else
                pool.start
              end
            else
              Bot.message(pool, "You're not the admin - you can't start pools!")
            end
          else
            Bot.message(pool, 'You have not been registered in this pool!')
          end
        else
          Bot.message(pool, 'You have not been registered for $tocklife!')
        end
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
      when 'trade'
        Bot.trade(pool)
      end
    end
    
    render :nothing => true
  end

  def register
    pool = Pool.create(:group_id => params[:group_id], :bot_id => params[:bot_id], :length => params[:length], :daily_plus => params[:daily_plus], :daily_minus => params[:daily_minus])
    Bot.message(pool, "$tocklife has been initialized for this pool! Type @help for commands, and @register to begin playing!")
    render :json => {:success => true}
  end

  def pool
    render 'ui/index'
  end

  def ping
    if params[:token] and params[:token] == '4db2e2382895e4b46d4008c2298f08280da89219b459043a33bc2e7cab537231ad50ffeba8e12c0a7d73de02b91718ad7d5efdbbd4bada60a75fa17fd3ed77b7'
      Pool.each(&:notify)
    end
  end

  private

  def verify_symbol
    if params[:sender_type] == 'bot'
      render :nothing => true and return
    elsif params[:text][0] != '@'
      pool = Pool.find_by(:group_id => params[:group_id])
      if pool
        pool.update(:message_count => pool.message_count + 1)
      end
    end
    params[:message] = params[:text][1..-1]
  end


end
