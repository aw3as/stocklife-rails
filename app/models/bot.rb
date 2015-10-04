class Bot

  def self.message(pool, message)
    Curl.post("https://api.groupme.com/v3/bots/post?bot_id=#{pool.bot_id}&text=#{CGI.escape(message)}")
  end

  def self.help(pool)
    Bot.message(pool, "Type @commands for a list of commands. For any other questions, please message us at (703) 409-7991")
  end

  def self.command(pool)
    Bot.message(pool, 'Available commands: @register, @help, @commands, @prices (or @price), @leaderboard, @admin, @start, @reset, @status, @trade, @[name] ++, @[name] ---, etc.')
  end

  def self.status(pool)
    Bot.message(pool, "$tocklife is alive and well!")
  end

  def self.trade(pool)
    Bot.message(pool, "To check your portfolio or buy and sell a stock, message us at (703) 409 – 7991. In your message, please include which stock you want to sell, which you want to buy, and what % of each you want to change")
  end

end