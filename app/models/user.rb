class User < ActiveRecord::Base
  has_many :participants

  has_many :pools, :through => :participants
end
