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
        render_headers(f, book)
        f.puts "<div style=\"text-align: center\">"
        f.puts "<h1>#{book['title']}</h1>"
        f.puts "<img src=\"#{book['cover-image']}\" />"
        f.puts "<h4>Authors: #{book['people']['authors'].join(', ')}</h4>"
        f.puts "<h4>Editors: #{book['people']['editors'].join(', ')}</h4>"
        f.puts "<h4>Typesetting: #{book['people']['typesetting'].join(', ')}</h4>"
        f.puts "<h4>ePub Conversion: #{book['people']['epub conversion'].join(', ')}</h4>"
        f.puts "<p>#{book['rights']}</p>"
        f.puts "</div>"
        render_footers(f)
      end

      html_files = ["title_page.html"]
      nav_sections = []

      book['chapters'].each do |chapter|
        page = @db.get(chapter)
        html_files << "#{page['_id']}.html"
        File.open("#{@dir_name}/#{html_files.last}", "w") do |f|
          section_html, section_nav = render_section(page, page['_id'])
          render_headers(f, chapter)
          f.puts(section_html)
          render_footers(f)
          nav_sections << section_nav if section_nav
        end
      end
      puts ''

      generate_epub(book, @dir_name, nav_sections, html_files)
      # epub = EeePub.make do
      #   title       book['title']
      #   creator     book['people']['authors'].join(', ')
      #   publisher   book['people']['epub conversion']
      #   date        Date.today.strftime('%B %d, %Y')
      #   identifier  book['identifier'], :scheme => 'URL'
      #   uid         book['uid']
      # 
      #   files html_files
      #   nav nav_sections
      # end
      # 
      # epub.save("fate_rpg.epub")
    end
  end

  def generate_epub(book, dir_name, nav_sections, files)
    EeePub::NCX.new(
      :uid => book['uid'],
      :title => book['title'],
      :nav => nav_sections
    ).save(File.join(dir_name, 'toc.ncx'))

    EeePub::OPF.new(
      :title => book['title'],
      :identifier => book['identifier'],
      :manifest => files,
      :ncx => 'toc.ncx'
    ).save(File.join(dir_name, 'content.opf'))

    EeePub::OCF.new(
      :dir => dir_name,
      :container => 'content.opf'
    ).save('fate_rpg.epub')  
  end
  
  def render_headers(f, chapter)
    f.puts "<?xml version=\"1.0\" encoding=\"windows-1250\"?>"
    f.puts "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\"
    \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">"
    f.puts "<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" >"
    f.puts "<head>"
    f.puts "<title>#{chapter['title']}</title>"
    f.puts "</head>"
    f.puts "<body>"    
  end
  
  def render_footers(f)
    f.puts "</body>"
    f.puts "</html>"    
  end
  
  def html_id(label, type='chapter')
    "#{type}-#{label.downcase.gsub(/[\W]+/,'-')}"
  end
  
  def escape_text(text)
    new_text = text.dup
    new_text.gsub!('<colgroup>','')
    new_text.gsub!('</colgroup>','')
    new_text.gsub!(/^<col.*/,'')
    new_text.gsub!('–','&mdash;')
    new_text.gsub!('‘','&lsquo;')
    new_text.gsub!('’','&rsquo;')
    new_text.gsub!('“','&ldquo;')
    new_text.gsub!('”','&rdquo;')
    new_text.gsub!(/^[\n\r]/,'') # empty lines
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
    section_html << escape_text(section_doc['body'])
    
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
