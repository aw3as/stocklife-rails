class Participant < ActiveRecord::Base
  belongs_to :pool
  belongs_to :user
end
