require 'lib/thor_includes'
class Fate < Thor
  desc 'create_fate_db', 'Parse the original fate rules and put into couchdb.'
  def create_fate_db(source_file, db_url)
    self.send('parse_fate_source', source_file, db_url)
  end
  
  desc 'build_fate_epub', 'Generate an epub for the Fate RPG'
  def build_fate_epub(file_name='fate_rpg.epub')
    self.send('build_epub', file_name)
  end
end
