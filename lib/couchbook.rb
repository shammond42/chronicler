class CouchBook
  attr_accessor :book_hash
  
  def initialize(doc, chapters)
    @book_hash = {:type => 'book'}
    
    @book_hash['_id'] = doc.css('div.document')[0].attributes['id'].value
    @book_hash['title'] = doc.css('h1.title').children.to_html
    @book_hash['uid'] = 'http://lostpapyr.us/fate/fate_srd.epub'
    @book_hash['identifier'] = 'http://lostpapyr.us/fate/fate_srd.epub'
    
    book_infos = doc.css('th.docinfo-name')
    book_infos.each do |book_info|
      key = book_info.children[0].to_s.downcase.sub(':','')
      value = book_info.parent.children.select{|child| child.name != 'text'}[1].children.to_html
      if key == 'copyright'
        @book_hash[key] = value
      else
        @book_hash['people'] = {} unless @book_hash['people']
        value.gsub!('<br>', ',')
        value.gsub!("\n",' ')
        name_list = value.split(/,|and/).map{|name| name.strip}
        @book_hash['people'][key] = name_list
      end
    end
    @book_hash['people']['epub-conversion'] = ['Steven Hammond']
    @book_hash['chapters'] = chapters
  end
  
  def save_to_couch(db_url)
    db = CouchRest.database!(db_url)
    
    db.save_doc(@book_hash)
    
    doc = db.get(@book_hash['_id'])
    
    image_name = 'cover-image.jpg'
    doc['cover-image-url'] = "#{db_url}/#{doc['_id']}/#{image_name}"
    doc.save
    puts doc.put_attachment(image_name, 
      File.open('./sources/pulp_cover_image.jpg')).inspect
    
    return doc['_id']
  end
end