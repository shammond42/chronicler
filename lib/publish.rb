module Chronicler
  module Publish
    def publish
      client.current_user.campaigns.each_with_index do |campaign, index|
        puts "#{index+1}: #{campaign.name} (#{campaign.role_as_title_string})"
      end
      print "\nSelect the campaign you want to publish: "
      index = STDIN.readline.chomp.to_i - 1
      
      campaign = client.current_user.campaigns[index]
      puts "\nSelected campagin: #{campaign.name}" if Configuration.verbose
      puts "Banner URL: #{campaign.banner_image_url}"
      puts "Page Count: #{campaign.posts.count}"
      
      campaign.players.each do |player|
        puts "#{player.username}: #{player.campaigns.count}"
      end
      # get campaign
      
      
      # get journals
    end
  end
  
  include Chronicler::Publish
end