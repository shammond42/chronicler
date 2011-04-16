require 'couchrest'
require 'ruby-debug'

module Chronicler
  module Fate
    def fate
      @db = CouchRest.database!("http://127.0.0.1:5984/fate")
      
      # pages = @db.view('fateapp/chapter_leads')
      book = @db.get("1d70236eaa3ce3b8c72f850b910002c0")
      @dir_name = 'book'
      Dir.mkdir(@dir_name) unless File.exists?(@dir_name)
      File.open("#{@dir_name}/title_page.html", "w") do |f|
        f.puts "<center>"
        f.puts "<h1>#{book['title']}</h1>"
        f.puts "<img src=\"#{book['cover-image']}\""
        f.puts "<h4>Authors: #{book['people']['authors'].join(', ')}</h4>"
        f.puts "<h4>Editors: #{book['people']['editors'].join(', ')}</h4>"
        f.puts "<h4>Typesetting: #{book['people']['typesetting'].join(', ')}</h4>"
        f.puts "<h4>ePub Conversion: #{book['people']['epub conversion'].join(', ')}</h4>"
        f.puts "<p>#{book['rights']}</p>"
        f.puts "</center>"
      end

      html_files = ["#{@dir_name}/title_page.html"]
      nav_sections = []

      book['chapters'].each do |chapter|
        page = @db.get(chapter)
        html_files << "book/#{page['_id']}.html"
        File.open(html_files.last, "w") do |f|
          section_html, section_nav = render_section(page, page['_id'])
          f.puts(section_html)
          nav_sections << section_nav if section_nav
        end
      end
      puts ''

      epub = EeePub.make do
        title       book['title']
        creator     book['people']['authors'].join(', ')
        publisher   book['people']['epub conversion']
        date        Date.today.strftime('%B %d, %Y')
        identifier  book['identifier'], :scheme => 'URL'
        uid         book['uid']

        files html_files
        nav nav_sections
      end

      epub.save("fate_rpg.epub")
    end
  end

  def html_id(label)
    label.downcase.gsub(/[\W]+/,'-')
  end
  
  def section_number(section_doc)
    section_doc['number'] ? section_doc['number'].join('.') : ''
  end
  
  def label_for(section_doc)
    "#{section_number(section_doc)} #{section_doc['title']}"
  end
  
  def render_section(section_doc, parent_id)
    section_html = ''

    unless section_doc['number'].nil?
      nav_section = {:label => label_for(section_doc), :content => 
        "#{parent_id}.html\##{html_id(label_for(section_doc))}", :nav => []}
      section_html << "<h#{section_doc['number'].size} id=\"#{html_id(label_for(section_doc))}\">"
      section_html << "#{label_for(section_doc)}"
      section_html << "</h#{section_doc['number'].size}>\n"
    end
    section_html << section_doc['body']
    
    if section_doc['subsections']
      section_doc['subsections'].each do |subsection|
        sub_html, sub_nav = render_section(@db.get(subsection), parent_id)
        section_html << sub_html
        nav_section[:nav] << sub_nav if nav_section && sub_nav
      end
    end
    print '.'
    return section_html, nav_section
  end
  
  include Chronicler::Fate
end
