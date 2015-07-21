class Participant < ActiveRecord::Base
  belongs_to :pool
  belongs_to :user

  has_many :sent_transactions, :class_name => Transaction, :foreign_key => :sender_id

  has_many :received_transactions, :class_name => Transaction, :foreign_key => :receiver_id

  def transact(participant, amount)
    sent_transactions.create(:receiver_id => participant.id, :amount => amount)
    Bot.message("#{user.name} has given #{participant.user.name} #{amount} points")
  end

  def total
    received_transactions.map(&:amount).sum
  end

end
