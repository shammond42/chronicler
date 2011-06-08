require 'lib/chronicle'

class Epub < Chronicle
  desc 'verify', 'Run verifier on an epub file.'
  def verify(file)
    puts "Verifiying #{file}."
    system "java -jar bin/epubcheck-1.2.jar #{file}"
  end
  
  desc 'clean', 'Clean up generated files and directories'
  def clean
    system "rm -rf tmp/*"
    puts 'Removed build directory.' if config[:verbose]
    system 'rm *.epub'
    puts 'Removed epub files.' if config[:verbose]
  end
end