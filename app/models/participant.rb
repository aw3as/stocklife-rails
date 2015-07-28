class Participant < ActiveRecord::Base
  belongs_to :pool
  belongs_to :user

  has_many :sent_transactions, :class_name => Transaction, :foreign_key => :sender_id, :dependent => :destroy

  has_many :received_transactions, :class_name => Transaction, :foreign_key => :receiver_id, :dependent => :destroy

  def transact(participant, amount)
    recent_transactions = sent_transactions.where(:created_at => Time.now.hour.hour.ago..Time.now)
    if amount > 0
      pluses = recent_transactions.map(&:amount).select do |value|
        value > 0
      end.sum
      if pluses == 10
        Bot.message(participant.pool, "You have reached your daily limit of 10 pluses!")
      elsif pluses + amount > 10
        amount = 10 - pluses
        sent_transactions.create(:receiver_id => participant.id, :amount => amount)
        Bot.message(participant.pool, "#{user.name} - after adding $#{amount} you've reached your daily limit of 10 pluses!")
      else
        sent_transactions.create(:receiver_id => participant.id, :amount => amount)
      end
    elsif amount < 0
      minuses = recent_transactions.map(&:amount).select do |value|
        value < 0
      end.sum
      if minuses == 5
        Bot.message(participant.pool, "You have reached your daily limit of 5 minuses!")
      elsif minuses + amount > 5
        amount = 5 - minuses
        sent_transactions.create(:receiver_id => participant.id, :amount => amount)
        Bot.message(participant.pool, "#{user.name} - after subtracting $#{amount} you've reached your daily limit of 5 minuses!")
      else
        sent_transactions.create(:receiver_id => participant.id, :amount => amount)
      end
    end
  end

  def total
    received_transactions.map(&:amount).sum
  end

end
