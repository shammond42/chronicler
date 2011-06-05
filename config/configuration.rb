module Configuration
  def self.config
    @@config ||= ActiveSupport::HashWithIndifferentAccess.new({
      # App specific key and secret for access to the Obsidian Portal API
      :consumer_key => '3Cvi9vXxnNFO2FfkT0aD',
      :consumer_secret => 'eVRnQzEOxm6wDrFAZjtN7pGzEy5gi2TzQSfyudPw',
      :config_file => File.expand_path('~/.chronicler/config.yml'),
      :saveable_keys => [:auth_token, :auth_secret]
    })
  end
  
  def config
    Configuration.config
  end
  
  # Called after loading the chronicler subclass of Thor
  def load_configuration
    config.merge!(options)
    if directory_exists?
      puts "Loading saved configuration." if config[:verbose]
      saved_opts = YAML::load_file(config[:config_file])
      config.merge!(saved_opts.to_hash)
      puts "Configuration loaded" if config[:verbose]
    else
      puts "Saved configuration not found." if config[:verbose]
      create_directory
      puts "Created configuration directory." if config[:verbose]
    end
  end
  
  # called before destroying an Chronicler instance.
  def self.save_configuration
    puts 'Saving configuration.' if config[:verbose]
    saved_opts = {}
    config[:saveable_keys].each{|key| saved_opts[key] = @@config[key]}
    
    File.open(config[:config_file], 'w') do |file|
      file.puts(saved_opts.to_yaml)
    end
    puts 'Configuration saved.' if config[:vebose]
  end
  
  def directory_exists?
    File.exist?(File.dirname(config[:config_file])) &&
      File.directory?(File.dirname(config[:config_file]))
  end
  
  def create_directory
    Dir.mkdir(File.dirname(config[:config_file]))
  end
end
include Configuration
