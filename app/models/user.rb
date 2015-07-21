class User < ActiveRecord::Base
  has_many :participants

  has_many :pools, :through => :participants

  def self.register(group_id, user_id, name)
    pool = Pool.find_by(:group_id => group_id)
    unless pool
      pool = Pool.create(:group_id => group_id)
    end
    user = User.find_by(:user_id => user_id)
    unless user
      user = User.create(:user_id => user_id, :name => name)
    end
    participant = Participant.create(:user_id => user.id, :pool_id => pool.id)
    Bot.message("#{user.name} has successfully registered!")
  end

end
