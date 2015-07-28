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
        Bot.message(participant.pool, "After adding $#{amount} you've reached your daily limit of 10 pluses!")
      else
        sent_transactions.create(:receiver_id => participant.id, :amount => amount)
      end
    elsif amount < 0
      minuses = recent_transactions.map(&:amount).select do |value|
        value < 0
      end.sum.abs
      if minuses == 5 or participant.total == 0
        if minuses == 5
          Bot.message(participant.pool, "You have reached your daily limit of 5 minuses!")
        else
          Bot.message(participant.pool, "#{participant.user.name}'s share price is already at $0!")
        end
      elsif minuses + amount.abs > 5 or participant.total - amount.abs < 0
        new_amount = [5 - minuses, participant.total].min
        sent_transactions.create(:receiver_id => participant.id, :amount => (new_amount * -1))
        if new_amount == 5 - minuses
          Bot.message(participant.pool, "After subtracting $#{new_amount} you've reached your daily limit of 5 minuses!")
        else
          Bot.message(participant.pool, "After subtracting $#{new_amount} #{participant.user.name}'s share price is at $#{participant.reload.total}!")
        end
      else
        sent_transactions.create(:receiver_id => participant.id, :amount => amount)
      end
    end
  end

  def total
    received_transactions.map(&:amount).sum + 2
  end

end
