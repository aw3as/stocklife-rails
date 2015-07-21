class User < ActiveRecord::Base
  has_many :participants

  has_many :pools, :through => :participants

  def self.register(pool, user)
    participant = Participant.create(:user_id => user.id, :pool_id => pool.id)
    Bot.message("#{user.name} has successfully registered!")
  end

end
