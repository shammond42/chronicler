require 'lib/chronicle'

class ObPort < Chronicle
  class_option :verbose, :type => :boolean, :default => false,
    :desc => 'give detailed descriptions of what is happening.'
    
  desc 'authorize', 'Authorize user for access to the obsidian portal account.'
  def authorize
    authorize_web_service
  end
  
  desc 'publish_journals', 'Publish a campaigns journals as an epub.'
  method_options :campaign => :string
  def publish_journals
    publish_web_journals
  end
end