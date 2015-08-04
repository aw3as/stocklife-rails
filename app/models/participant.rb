class Participant < ActiveRecord::Base
  belongs_to :pool
  belongs_to :user

  has_many :stocks, -> { where "participant_id IS NOT NULL" }, :foreign_key => :owner_id, :dependent => :destroy
  has_one :cash, -> { where participant_id: nil }, :dependent => :destroy, :foreign_key => :owner_id, :class_name => Stock

  has_many :sent_transactions, :class_name => Transaction, :foreign_key => :sender_id, :dependent => :destroy
  has_many :received_transactions, :class_name => Transaction, :foreign_key => :receiver_id, :dependent => :destroy

  def transact(participant, amount, admin = false)
    recent_transactions = sent_transactions.where(:created_at => Time.now.hour.hour.ago..Time.now)
    if amount > 0
      pluses = recent_transactions.map(&:amount).select do |value|
        value > 0
      end.sum
      if admin
        sent_transactions.create(:receiver_id => participant.id, :amount => amount)
      else
        if pluses >= pool.daily_plus
          Bot.message(participant.pool, "You have reached your daily limit of #{pool.daily_plus} pluses!")
        elsif pluses + amount > pool.daily_plus
          amount = pool.daily_plus - pluses
          sent_transactions.create(:receiver_id => participant.id, :amount => amount)
          Bot.message(participant.pool, "After adding #{Money.new(amount * 100).format[0..-4]} you've reached your daily limit of #{pool.daily_plus} pluses!")
        else
          sent_transactions.create(:receiver_id => participant.id, :amount => amount)
        end
      end
    elsif amount < 0
      minuses = recent_transactions.map(&:amount).select do |value|
        value < 0
      end.sum.abs
      if admin
        sent_transactions.create(:receiver_id => participant.id, :amount => amount)
      else
        if minuses >= pool.daily_minus or participant.price == 0
          if minuses >= pool.daily_minus
            Bot.message(participant.pool, "You have reached your daily limit of #{pool.daily_minus} minuses!")
          else
            Bot.message(participant.pool, "#{participant.user.name}'s share price is already at $0!")
          end
        elsif minuses + amount.abs > pool.daily_minus or participant.price - amount.abs < 0
          new_amount = [pool.daily_minus - minuses, participant.price].min
          sent_transactions.create(:receiver_id => participant.id, :amount => (new_amount * -1))
          if new_amount == pool.daily_minus - minuses
            Bot.message(participant.pool, "After subtracting #{Money.new(new_amount * 100).format[0..-4]} you've reached your daily limit of #{pool.daily_minus} minuses!")
          else
            Bot.message(participant.pool, "After subtracting #{Money.new(new_amount * 100).format[0..-4]} #{participant.user.name}'s share price is at #{Money.new(participant.reload.price * 100).format[0..-4]}!")
          end
        else
          sent_transactions.create(:receiver_id => participant.id, :amount => amount)
        end
      end
    end
  end

  def price(time = Time.now)
    received_transactions.where(:created_at => Time.at(0)..time).map(&:amount).sum + pool.start_price
  end

  def portfolio_value(time = Time.now)
    stocks.map do |stock|
      stock.amount * stock.participant.price(time)
    end.sum + cash.amount
  end

  def portfolio(time = Time.now)
    header = %w(Name Shares Price Total Percentage).join("\t\t")
    stock_lines = stocks.reload.map do |stock|
      [stock.participant.user.name[0..6], stock.amount, Money.new(stock.participant.price(time) * 100).format[0..-4], Money.new(stock.value(time) * 100).format[0..-4], (stock.value(time).to_f / portfolio_value(time) * 100).round(1)].join("\t\t")
    end
    cash_line = ["Cash", "N/A", "N/A", Money.new(cash.amount * 100).format[0..-4], (cash.amount.to_f / portfolio_value(time) * 100).round(1)].join("\t\t")
    total_line = ["Total", "N/A", "N/A", Money.new(portfolio_value(time) * 100).format[0..-4], "100%"].join("\t\t")
    [header, *stock_lines, cash_line, total_line].join("\n")
  end

  def buy(participant, amount, time = Time.now)
    stock = stocks.find_by(:participant => participant)
    total = participant.price(time) * amount
    if cash.amount >= total
      puts "decrementing cash by #{total}"
      puts "cash going from #{cash.amount} to #{cash.amount - total}"
      cash.update(:amount => cash.amount - total)

      puts "incrementing stock by #{amount}"
      puts "stock going from #{stock.amount} to #{stock.amount + amount}"
      stock.update(:amount => stock.amount + amount)
    else
      puts 'failed to buy due to insufficient funds!'
    end
  end

  def sell(participant, amount, time = Time.now)
    stock = stocks.find_by(:participant => participant)
    if amount <= stock.amount
      puts "incrementing cash by #{total}"
      puts "cash going from #{cash.amount} to #{cash.amount + participant.price(time) * amount}"
      cash.update(:amount => cash.amount + participant.price(time) * amount)

      puts "decrementing stock by #{amount}"
      puts "stock going from #{stock.amount} to #{stock.amount - amount}"
      stock.update(:amount => stock.amount - amount)
    else
      puts 'failed to sell due to insufficient stock!!'
    end
  end

  def set_percentage(participant, percentage, time = Time.now)
    stock = stocks.find_by(:participant => participant)
    current_percentage = stock.value(time).to_f / portfolio_value(time) * 100
    amount = ((percentage / 100.0) * portfolio_value(time)) / participant.price(time)
    if percentage < current_percentage
      puts "selling from #{current_percentage.round(2)}% to #{percentage}%"
      puts "selling from #{stock.amount} shares - #{current_percentage.round(2)}% to #{amount} shares - #{percentage.round(2)}%"
      puts "selling #{stock.amount - amount} shares"
      sell(participant, stock.amount - amount, time)
    elsif percentage > current_percentage
      puts "buying to #{current_percentage.round(2)}% from #{percentage}%"
      puts "buying to #{stock.amount} shares - #{current_percentage.round(2)}% from #{amount} shares - #{percentage.round(2)}%"
      puts "buying #{stock.amount - amount} shares"
      puts "buying to #{current_percentage.round(2)}% from #{percentage}%"
      buy(participant, amount - stock.amount, time)
    end
  end

  def percentage(participant, time = Time.now)
    stock = stocks.find_by(:participant => participant)
    (stock.value(time).to_f / portfolio_value(time)).round(2)
  end

end
