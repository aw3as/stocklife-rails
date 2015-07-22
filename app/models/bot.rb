class Bot

  def self.message(pool, message)
    Curl.post("https://api.groupme.com/v3/bots/post?bot_id=#{pool.bot_id}&text=#{CGI.escape(message)}")
  end

  def self.help(pool)
    Bot.message(pool, 'Welcome to $tocklife! @ prepends all commands, like @total, @register, @help, @leaderboard')
  end

  def self.command(pool)
    Bot.message(pool, 'Available commands: @total, @register, @help, @leaderboard, @[name] ++, @[name] ---, etc.')
  end

end