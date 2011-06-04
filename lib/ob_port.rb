module ObsidianPortal
  def authorize_web_service
    load_configuration
    request_token = client.consumer.get_request_token

    if config[:auth_token] && config[:auth_secret]
      begin
        print "Chronicler has already been authorized. Do you want to authorize again?[Yn] "
        auth_again = STDIN.readline.chomp
      end until auth_again =~ /^[yYnN]?$/
      return if auth_again =~ /^[nN]$/
    end

    puts "Put #{request_token.authorize_url} in your browser"

    print "Enter the supplied pin (or verifier): "
    pin = STDIN.readline.chomp

    access_token = request_token.get_access_token(:oauth_verifier => pin)
    Configuration.auth_token = access_token.token
    Configuration.auth_secret = access_token.secret

    # print "Enter token: "
    # Configuration.auth_token = STDIN.readline.chomp
    # print "Enter secret: "
    # Configuration.auth_secret = STDIN.readline.chomp

    Configuration.save!
    puts "Saved authorization information." if config[:verbose]
  end
end

include ObsidianPortal