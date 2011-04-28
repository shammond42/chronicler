require 'couchrest'
require 'ruby-debug'

module Fate
  def fate(file_name='fate_rpg.epub')
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
      html_files << page_file_name(page)
      File.open("#{@dir_name}/#{html_files.last}", "w") do |f|
        section_html, section_nav = render_section(page, html_files.last)
        render_headers(f, page)
        f.puts(section_html)
        render_footers(f)
        nav_sections << section_nav if section_nav
      end
    end
    puts ''

    generate_epub(file_name, book, @dir_name, nav_sections, html_files)
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

def page_file_name(page)
  "chapter-#{'%02d' % page['number'][0]}.html"
end

def generate_epub(file_name, book, dir_name, nav_sections, files)
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
  ).save(file_name)  
end

def render_headers(f, chapter)
  f.puts "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
  f.puts "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\"
  \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">"
  f.puts "<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" >"
  f.puts "<head>"
  f.puts "<title>#{page_title(chapter)}</title>"
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

def page_title(page)
  if page['number']
    return "Chapter #{page['number'][0]}: #{page['title']}"
  else
    return page['title']
  end
end

def escape_text(text)
  new_text = text.dup
  new_text.gsub!('<colgroup>','')
  new_text.gsub!('</colgroup>','')
  new_text.gsub!(/<blockquote( class="\w+")?>/,"<blockquote\\1><div>")
  new_text.gsub!('</blockquote>','</div></blockquote>')
  new_text.gsub!(/id="(id\d+)"\s+name="id\d+"/,"id=\"\\1\"")
  new_text.gsub!('name=','id=')
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

def render_section(section_doc, file_name)
  section_html = ''

  unless section_doc['number'].nil?
    nav_section = {:label => label_for(section_doc), :content => 
      "#{file_name}\##{html_id(label_for(section_doc))}", :nav => []}
    section_html << "<h#{section_doc['number'].size} id=\"#{html_id(label_for(section_doc))}\">"
    section_html << "#{label_for(section_doc)}"
    section_html << "</h#{section_doc['number'].size}>\n"
  end
  section_html << escape_text(section_doc['body'])
  
  if section_doc['subsections']
    section_doc['subsections'].each do |subsection|
      sub_html, sub_nav = render_section(@db.get(subsection), file_name)
      section_html << sub_html
      nav_section[:nav] << sub_nav if nav_section && sub_nav
    end
  end
  print '.'
  return section_html, nav_section
end

