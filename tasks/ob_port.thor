require 'lib/chronicle'

class ObPort < Chronicle
  class_option :verbose, :type => :boolean, :default => false,
    :desc => 'give detailed descriptions of what is happening.'
    
  desc 'authorize', 'Authorize user for access to the obsidian portal account.'
  def authorize
    self.send('authorize_web_service')
  end
end