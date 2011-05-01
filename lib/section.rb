class Section
  attr_accessor :number, :title, :body, :subsections
  
  def initialize
    @subsections = []
  end
  
  def save_to_couch(db)
    section_hash = {
      :number => self.number,
      :title => self.title,
      :body => escape_text(self.body)
    }

    self.subsections.each do |subsection|
      section_hash[:subsections] = [] if section_hash[:subsections].nil?
      section_hash[:subsections] << subsection.save_to_couch(db)
    end
    
    return db.save_doc(section_hash)['id']
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
  
  def self.get_headers(element)
    element.children.select{|child| child.name =~ /h\d/}
  end
  
  def self.strip_section_num!(header)
    section_num = header.scan(/^([\d\.]+)/)[0][0] if header.scan(/^([\d\.]+)/)[0]
    header.sub!(/^[\d\.]+[\302\240]+/,'')   
    return section_num 
  end
  
  def self.process_dom(element)
    section = Section.new
    
    if get_headers(element).count != 1
      puts "Incorrect number of headers for section."
    end
    section.title = get_headers(element)[0].text
    
    get_headers(element)[0].remove # remove the header
    
    num_text = strip_section_num!(section.title)
    section.number = num_text.split('.').map(&:to_i) unless num_text.nil?
    
    subsections = element.children.select{|child| (child.name =~ /div/) &&
      (child.attributes['class'].value == 'section')}
    
    subsections.each do |subsection|
      section.subsections << Section.process_dom(subsection)
      subsection.remove
    end
    section.body = element.inner_html
    
    return section
  end
  
  def self.print_sections(sections)
    sections.each do |section|
      puts "#{section.number}: #{section.title}"
      puts section.body
      Section.print_sections(section.subsections)
    end
  end

  def self.store_text(db_url, sections)
    db = CouchRest.database!(db_url)
    chapter_ids = []
    sections.each do |section|
      chapter_ids << section.save_to_couch(db)
    end
    
    chapter_ids
  end
end