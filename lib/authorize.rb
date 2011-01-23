module Chronicler
  module Authorize
    def authorize
      request_token = Configuration.client.consumer.get_request_token

      if Configuration.auth_token && Configuration.auth_secret
        begin
          print "Chronicler has already been authorized. Do you want to authorize again?[Yn] "
          auth_again = STDIN.readline.chomp
        end until auth_again =~ /^[yYnN]?$/
        return if auth_again =~ /^[nN]$/
      end
      
      puts "Put #{request_token.authorize_url} in your browser"
      print "Enter token: "
      Configuration.auth_token = STDIN.readline.chomp
      print "Enter secret: "
      Configuration.auth_secret = STDIN.readline.chomp
      
      Configuration.save!
      puts "Saved authorization information." if Configuration.verbose
    end
  end
  
  include Chronicler::Authorize
end