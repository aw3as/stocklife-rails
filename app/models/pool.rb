class Pool < ActiveRecord::Base
  has_many :participants, :dependent => :destroy

  has_many :users, :through => :participants
  has_many :transactions, :through => :participants, :source => :sent_transactions

  def admin
    participants.order(:created_at).first
  end

  def wipe
    transactions.each(&:destroy)
  end

  def start
    if participants.count < minimum_person
      Bot.message(self, "You don't have enough people to start a $tocklife pool! You currently have #{participants.count} out of #{minimum_person} needed!")
    else
      participants.permutation(2).each do |first_participant, second_participant|
        Stock.create(:owner_id => first_participant.id, :participant_id => second_participant.id)
      end
      participants.each do |participant|
        Stock.create(:owner_id => participant.id, :amount => start_cash)
        Stock.create(:owner_id => participant.id, :participant_id => participant.id)
      end
      update(:started => true)
      update(:started_at => Time.now)
      Bot.message(self, "The $tocklife pool has been started! Everyone starts with #{Money.new(start_cash * 100).format}")
    end
  end

  def stop
    update(:started => false)
    update(:started_at => nil)
  end

  def restart
    participants.flat_map(&:stocks).compact.each(&:destroy)
    participants.map(&:cash).compact.each(&:destroy)
    wipe
    start
  end

  def prices
    message = ""
    participants.sort_by(&:price).reverse.each_with_index do |participant, index|
      message += "#{index + 1}. #{participant.user.name}: #{Money.new(participant.price * 100).format[0..-4]}\n"
    end
    message
  end

  def leaderboard
    message = ""
    participants.sort_by(&:portfolio_value).reverse.each_with_index do |participant, index|
      message += "#{index + 1}. #{participant.user.name}: #{Money.new(participant.portfolio_value * 100).format[0..-4]}\n"
    end
    message
  end

  def days_left
    ((started_at + length.days).to_date - Time.now.to_date).to_i
  end

  def notify
    if pool.started
      Bot.message(self, pool.leaderboard)
      if days_left == 0
        best_price = participants.sort_by(&:price).reverse.first
        best_portfolio = participants.sort_by(&:portfolio_value).reverse.first
        Bot.message("The game has ended! #{best_price.user.name} has the best price at $#{best_price.user.price}, and #{best_portfolio.user.name} has the best portfolio at $#{best_portfolio.portfolio_value}! Congratulations! To restart - have #{admin.user.name} type @start to begin again!")
        stop
      else
        Bot.message(self, "There #{days_left == 1 ? 'is' : 'are'} #{days_left} #{'days'.pluralize(days_left)} left in the game! This is checked everyday at 5PM EST.")
      end
    end
  end

end
