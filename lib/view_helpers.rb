module ViewHelpers
  def get_image(uri)
    Dir.mkdir('book/images') unless File.exists?('book/images')

    url = URI.parse(uri)
    # host = url.sub('http://','').sub(/\/.*/,'')
    # path = url.sub(/http:\/\/[^\/]+/,'')
    file_name = "images/" << url.path.split('/').last

    Net::HTTP.start(url.host, url.port) { |http|
      resp = http.get(url.path)
      File.open("book/#{file_name}", 'wb') { |file|
        file.write(resp.body)
      }
    }
    print 'i'
    return file_name
  end
end