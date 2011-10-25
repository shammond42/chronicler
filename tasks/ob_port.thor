require 'lib/chronicle'

class ObPort < Chronicle
  desc 'authorize', 'Authorize user for access to the obsidian portal account.'
  def authorize
    authorize_web_service
  end
  
  desc 'show_config', 'Display authorization details on the console'
  def show_config
    show_ob_port_config
  end
  
  desc 'publish_journals', 'Publish a campaigns journals as an epub.'
  method_options :campaign => :string
  def publish_journals
    publish_web_journals
  end
end