class Section
  attr_accessor :number, :title, :body, :subsections
  
  def initialize
    @subsections = []
  end
  
  def save_to_couch(db)
    section_hash = {
      :number => self.number,
      :title => self.title,
      :body => self.body
    }

    self.subsections.each do |subsection|
      section_hash[:subsections] = [] if section_hash[:subsections].nil?
      section_hash[:subsections] << subsection.save_to_couch(db)
    end
    
    return db.save_doc(section_hash)['id']
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
    sections.each do |section|
        puts section.save_to_couch(db)
      end
  end
end