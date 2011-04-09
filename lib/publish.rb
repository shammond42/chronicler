require 'eeepub'
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

      File.open("/tmp/title_page.html", "w") do |f|
        f.print "<center>"
        f.print "<h1>#{campaign.name}</h1>"
        f.print "<img src='#{campaign.banner_image_url}' />" unless campaign.banner_image_url.nil?
        f.print "</center>"
      end

      html_files = ["/tmp/title_page.html"]
      nav_sections = []

      campaign.posts.each do |post|
        html_files << "/tmp/#{post.id}.html"
        label = "#{post.created_at.to_date} - #{post.post_title}"
        nav_sections << {:label => label, :content => "#{post.id}.html"}
        File.open(html_files.last, "w") do |f|
          f.print "<h1>#{label}</h1>"
          f.print "<h2>#{post.post_tagline}</h2>" unless post.post_tagline.nil?
          f.print post.body_html
        end
      end

      epub = EeePub.make do
        title       campaign.name
        creator     campaign.game_master_id # TODO
        publisher   campaign.game_master_id # TODO
        date        Date.today
        identifier  campaign.campaign_url, :scheme => 'URL'
        uid         campaign.id

        files html_files
        nav nav_sections
      end

      epub.save("campaign.epub")
    end
  end
  
  include Chronicler::Publish
end
