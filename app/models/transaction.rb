class Transaction < ActiveRecord::Base
  belongs_to :sender, :class_name => Participant
  belongs_to :receiver, :class_name => Participant
end
