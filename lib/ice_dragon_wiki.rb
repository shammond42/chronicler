require 'mechanize'

module IceDragonWiki
  def transfer_pages
    # Get the campaign to send pages to
    get_campaign_from_current_user
    
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
      links.each{|l| puts "#{date_from_link(l.text)}: #{l.text}"}
    end
  end
  
  def date_from_link(link_text)
    Date.parse(link_text.match(/\((.*20\d\d)\)$/)[0])
  end

  def has_date?(link_text)
    link_text =~ /\(.*20\d\d\)$/
  end  
end

include IceDragonWiki