module Chronicler
  def init
    Configuration.init
  end
  
  def client
    Configuration.client
  end
end