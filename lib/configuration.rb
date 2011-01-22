require 'lib/trollop'

module Chronicler
  module Configuration
    SUB_COMMANDS = %w(authorize)
    CONFIG_FILE = File.expand_path('~/.chronicler/config.yml')
    CONFIG_DIRECTORY = File.dirname(CONFIG_FILE)

    # App specific key and secret for access to the API
    CONSUMER_KEY = '3Cvi9vXxnNFO2FfkT0aD'
    CONSUMER_SECRET = 'eVRnQzEOxm6wDrFAZjtN7pGzEy5gi2TzQSfyudPw'

    def self.load
      parse_command_line
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
    
    protected
    
    def self.parse_command_line
      global_opts = Trollop::options do
        version "pre-alpha 0.0.1"
        banner "convert Obsidian Portal adventure logs into off-line formats."
        opt :verbose, "Act like the chatty gnome bard", :short => "-v"
        stop_on SUB_COMMANDS
      end

      cmd = ARGV.shift # get the subcommand
      cmd_opts = case cmd
        when "authorize" # parse delete options
          Trollop::options do
            opt :key, "Authorization key"
            opt :secret, "Authorization secret"
          end
        when "copy"  # parse copy options
          Trollop::options do
            opt :double, "Copy twice for safety's sake"
          end
        else
          Trollop::die "unknown subcommand #{cmd.inspect}"
        end

      # puts "Global options: #{global_opts.inspect}"
      # puts "Subcommand: #{cmd.inspect}"
      # puts "Subcommand options: #{cmd_opts.inspect}"
      # puts "Remaining arguments: #{ARGV.inspect}"
    end
  end
end
