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

end
