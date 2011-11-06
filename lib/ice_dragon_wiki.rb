require 'mechanize'

module IceDragonWiki
  def transfer_pages
    # Get the campaign to send pages to
    campaign = get_campaign_from_current_user
  
    # Start with a particular post
    print "\nWhich post do you want to start processing: "
    starting_post = STDIN.readline.chomp.to_i
    
    a = Mechanize.new
    
    a.get('http://www.icedragon.ca/wiki/index.php?title=Main_Page') do |page|
      login_page = a.click(page.link_with(:text => /Log in/))
    
      landing_page = login_page.form_with(:action =>
        '/wiki/index.php?title=Special:Userlogin&action=submitlogin&type=login&returnto=Main_Page') do |f|
          f.wpName = 'shammond42'
          f.wpPassword = 'qns2fck'
      end.click_button
    
      history_page = a.click(landing_page.link_with(:text => /Session Notes/))
      links = history_page.links.select{|l| has_date?(l.text)}.sort_by{|l| date_from_link(l.text)}
      count = 0
      links.each do |link|
        count += 1
        if count >= starting_post
          puts "#{count}: #{date_from_link(link.text)}: #{title_from_link(link.text)}"
          post_page = link.click
          edit_page = post_page.links_with(:text =>'Edit').first.click
      
          new_post = MageHand::WikiPage.new(
            :campaign => {:id => campaign.id},
            :is_game_master_only => false,
            :post_title => title_from_link(link.text),
            :post_time => date_from_link(link.text),
            :body => transform_formatting(edit_page.search('#wpTextbox1').inner_html),
            :tags => ['ice_dragon', 'auto'],
            :type => 'Post'
          )
      
          begin
            new_post.save!
            puts new_post.id
          rescue
            puts "FAIL"
          end
        elsif
          puts "#{date_from_link(link.text)}: #{title_from_link(link.text)}: SKIPPED"
        end
      end
    end
  end
  
  def date_from_link(link_text)
    Date.parse(link_text.match(/\((.*20\d\d)\)$/)[0])
  end

  def title_from_link(link_text)
    link_text.split(/\((.*20\d\d)\)$/)[0]
  end
  
  def has_date?(link_text)
    link_text =~ /\(.*20\d\d\)$/
  end
  
  def transform_formatting(mw_string)
    tx_string = mw_string.dup
    tx_string.gsub!(";",',')
    tx_string.gsub!("'''",'*')
    tx_string.gsub!("''",'_')
    tx_string.gsub!(/^\=\=\=(.*)\=\=\=/,'h3. \1')
    tx_string.gsub!(/^\=\=(.*)\=\=/,'h2. \1')
    tx_string.gsub!(/^\=(.*)\=/,'h1. \1')
    
    tx_string
  end
  
end

include IceDragonWiki