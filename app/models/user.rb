class User < ActiveRecord::Base
  has_many :participants, :dependent => :destroy

  has_many :pools, :through => :participants

  def self.register(pool, user)
    participant = Participant.create(:user_id => user.id, :pool_id => pool.id)
    if pool.participants.count == 1
      Bot.message(pool, "#{user.name} has successfully registered as an admin!")
    else
      Bot.message(pool, "#{user.name} has successfully registered!")
    end
  end

end
