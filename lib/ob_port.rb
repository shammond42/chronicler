module ObsidianPortal
  def authorize_web_service
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
    config[:auth_token] = access_token.token
    config[:auth_secret] = access_token.secret
    # will save info on exit
  end
end

include ObsidianPortal