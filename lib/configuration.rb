module Chronicler
  module Configuration
    CONFIG_FILE = File.expand_path('~/.chronicler/config.yml')
    CONFIG_DIRECTORY = File.dirname(CONFIG_FILE)

    # App specific key and secret for access to the API
    CONSUMER_KEY = '3Cvi9vXxnNFO2FfkT0aD'
    CONSUMER_SECRET = 'eVRnQzEOxm6wDrFAZjtN7pGzEy5gi2TzQSfyudPw'

    def self.load
      MageHand::Client.configure(CONSUMER_KEY, CONSUMER_SECRET)
      if directory_exists?
        
      else
        create_directory
      end
    end
    
    def self.save
      File.open(CONFIG_FILE, 'w') do |file|
        file.puts(parameters.to_yaml)
      end  
    end
    
    def self.directory_exists?
      File.exist?(CONFIG_DIRECTORY) && File.directory?(CONFIG_DIRECTORY)
    end
    
    def self.create_directory
      Dir.mkdir(CONFIG_DIRECTORY)
    end
    
    def self.parameters
      @parameters ||= {}
    end
  end
end
