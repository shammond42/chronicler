module Chronicler
  module Publish
    def publish
      client.current_user.campaigns.each_with_index do |campaign, index|
        puts "#{index+1}: #{campaign.name} (#{campaign.role_as_title_string})"
      end
      print "\nSelect the campaign you want to publish: "
      index = STDIN.readline.chomp.to_i - 1
      
      puts "\nSelected campagin: #{Configuration.client.current_user.campaigns[index].name}"
      # get campaign
      # get journals
    end
  end
  
  include Chronicler::Publish
end