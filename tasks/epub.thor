class Epub < Thor
  require 'lib/thor_includes'
  
  desc 'build_fate', 'Generate an epub for the Fate RPG'
  def build_fate(file_name='fate_rpg.epub')
    # fate(file_name)
    self.send('fate', file_name)
  end
  
  desc 'verify', 'Run verifier on an epub file.'
  def verify(file)
    puts "Verifiying #{file}."
    system "java -jar bin/epubcheck-1.2.jar #{file}"
  end
  
  desc 'clean', 'Clean up generated files and directories'
  def clean
    system 'rm -rf book'
    puts 'Removed build directory.'
    system 'rm *.epub'
    puts 'Removed epub files.'
  end
end
