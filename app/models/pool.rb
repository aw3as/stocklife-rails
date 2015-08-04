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
      end
      update(:started => true)
      Bot.message(self, "The $tocklife pool has been started! Everyone starts with #{Money.new(start_cash * 100).format}")
    end
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

end
