module Chronicler
  module Publish
    def publish
      puts Configuration.client.current_user.inspect
      # get campaign
      # get journals
    end
  end
  
  include Chronicler::Publish
end