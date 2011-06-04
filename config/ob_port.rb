module ObsidianPortal  
  def client
    unless defined? @@client
      puts "Initializing OAuth client" if config[:verbose]
      MageHand::Client.configure(config[:consumer_key], config[:consumer_secret])
      @@client = MageHand::Client.new(nil, config[:auth_token], config[:auth_secret])
    end
    @@client
  end
end
