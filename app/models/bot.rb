class Bot

  def self.message(message)
    Curl.post("https://api.groupme.com/v3/bots/post?bot_id=fab0cad741b6d1a7f1b02e19e8&text=#{CGI.escape(message)}")
  end

  def self.help
    Bot.message('Welcome to $tocklife! @ prepends all commands, like @total, @register, @help')
  end

end