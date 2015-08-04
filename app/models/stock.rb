class Stock < ActiveRecord::Base
  belongs_to :owner, :class_name => Participant
  belongs_to :participant

  def value(time = Time.now)
    amount * participant.price(time)
  end

end