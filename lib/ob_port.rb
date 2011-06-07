module ObsidianPortal
  def authorize_web_service
    request_token = op_client.consumer.get_request_token

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
  
  def publish_web_journals
    puts 'Determining which campaign to use.' if config[:verbose]
    campaign = if config[:campaign]
      MageHand::Campaign.find_by_slug(config[:campaign])
    else
      get_campaign_from_current_user
    end

    if config[:verbose]
      puts "Campaign ID: #{campaign.id}"
      puts "\nSelected campagin: #{campaign.name}"
      puts "Banner URL: #{campaign.banner_image_url}"
      puts "Page Count: #{campaign.posts.count}"
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
      print "."
    end
    puts ''

    epub = EeePub.make do
      title       campaign.name
      creator     campaign.players.map(&:username) << campaign.game_master.username
      publisher   campaign.game_master.username
      date        Date.today
      identifier  campaign.campaign_url, :scheme => 'URL'
      uid         campaign.id

      files html_files
      nav nav_sections
    end

    epub.save("#{campaign.slug}.epub")
  end
  
  private
  
  def op_client
    unless defined? @@op_client
      puts "Initializing OAuth op_client" if config[:verbose]
      MageHand.set_app_keys(config[:consumer_key], config[:consumer_secret])
      @@op_client = MageHand::get_client(nil, config[:auth_token], config[:auth_secret])
    end
    @@op_client
  end
  
  def get_campaign_from_current_user
    op_client.current_user.campaigns.each_with_index do |campaign, index|
      puts "#{index+1}: #{campaign.name} (#{campaign.role_as_title_string})"
    end
    print "\nSelect the campaign you want to publish: "
    index = STDIN.readline.chomp.to_i - 1

    op_client.current_user.campaigns[index]
  end
end

include ObsidianPortal