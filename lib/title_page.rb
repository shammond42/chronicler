class TitlePage < Mustache
  include ViewHelpers
  
  attr_accessor :title, :people, :rights
  attr_writer :cover_image
  
  def cover_image
    @retrieved_cover_image ||= get_image(@cover_image)
  end
  
  %w(authors editors typesetting epub-conversion).each do |method|
    send :define_method, method do
      @people[method].join(', ')
    end
  end
end