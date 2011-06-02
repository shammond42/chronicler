
module Fate
  def parse_fate_source(source_file, db_url)
    doc = Nokogiri::HTML(File.open(source_file))

    # Search for nodes by css
    puts doc.css('div.section').size

    sections = []
    doc.css('div.document > div.section').each do |section|
      sections << Section.process_dom(section)
    end

    chapters = Section.store_text(db_url, sections)

    book = CouchBook.new(doc, chapters)
    puts book.save_to_couch(db_url)  
  end
  
  def build_epub(file_name='fate_rpg.epub')
    @db = CouchRest.database!("http://127.0.0.1:5984/fate")
    
    # pages = @db.view('fateapp/chapter_leads')
    book = @db.get("sotc-srd")
    @dir_name = 'book'
    @file_list = []
    
    Dir.mkdir(@dir_name) unless File.exists?(@dir_name)
    File.open("#{@dir_name}/title_page.html", "w") do |f|
      title_page = TitlePage.new
      title_page.title = book['title']
      title_page.cover_image = book['cover-image-url']
      @file_list << title_page.cover_image
      title_page.people = book['people']
      title_page.rights = book['rights']
      f.puts title_page.render
    end
    
    @file_list << "title_page.html"
    nav_sections = []

    book['chapters'].each do |chapter|
      page = @db.get(chapter)
      @file_list << page_file_name(page)
      File.open("#{@dir_name}/#{@file_list.last}", "w") do |f|
        section_html, section_nav = render_section(page, @file_list.last)
        render_headers(f, page)
        f.puts(section_html)
        render_footers(f)
        nav_sections << section_nav if section_nav
      end
    end
    puts ''

    generate_epub(file_name, book, @dir_name, nav_sections, @file_list)
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

def type(depth)
  if depth == 1
    'chapter'
  else
    type_string = ''
    (depth-2).times{type_string << 'sub-'}
    type_string << 'section'
  end
end

def html_id(label, depth=0)
  "#{type(depth)}-#{label.downcase.gsub(/[\W]+/,'-')}"
end

def page_title(page)
  if page['number']
    return "Chapter #{page['number'][0]}: #{page['title']}"
  else
    return page['title']
  end
end

def section_number(section_doc)
  section_doc['number'].size < 4 ? section_doc['number'].join('.') : ''
end

def label_for(section_doc)
  label = "#{section_number(section_doc)}"
  label << ' ' unless label.blank?
  label << "#{section_doc['title']}"
end

def render_section(section_doc, file_name)
  section_html = ''

  unless section_doc['title'].blank?
    nav_section = {:label => label_for(section_doc), :content => 
      "#{file_name}\##{html_id(label_for(section_doc), section_doc['number'].size)}", :nav => []}
    section_html << "<h#{section_doc['number'].size} id=\"#{html_id(label_for(section_doc),section_doc['number'].size)}\">"
    section_html << "#{label_for(section_doc)}"
    section_html << "</h#{section_doc['number'].size}>\n"
  end
  section_html << section_doc['body']
  
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

