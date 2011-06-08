class Chapter < Mustache
  attr_accessor :title, :subtitle, :body
  
  def initialize(title, subtitle, body)
    self.title = title
    self.subtitle = subtitle
    self.body = body
  end
  
  def render_to_file
    File.open(html_files.last, "w"){|f| f.print self.render}
  end
  
  def file_path
    "#{config[:temp_dir]}/#{file_name}"
  end
  
  def file_name
    "#{title.downcase.gsub(/[\W]+/,'-')}.html"
  end
end