class Epub < Thor
  desc 'verify', 'Run verifier on an epub file.'
  def verify(file)
    puts "Verifiying #{file}."
    system "java -jar bin/epubcheck-1.2.jar #{file}"
  end
end
