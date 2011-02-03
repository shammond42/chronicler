require 'lib/trollop'

class Configuration  
  SUB_COMMANDS = %w(authorize publish)
  CONFIG_FILE = File.expand_path('~/.chronicler/config.yml')
  CONFIG_DIRECTORY = File.dirname(CONFIG_FILE)

  # App specific key and secret for access to the API
  CONSUMER_KEY = '3Cvi9vXxnNFO2FfkT0aD'
  CONSUMER_SECRET = 'eVRnQzEOxm6wDrFAZjtN7pGzEy5gi2TzQSfyudPw'

  @@opts = {}
  
  def self.method_missing(m, *args, &block)
    if @@opts.has_key?(m)
      return @@opts[m]
    elsif m.to_s =~ /=$/
      @@opts[m.to_s.chop.to_sym] = args[0]
    else
      super.method_missing(m, *args, &block)
    end  
  end  

  def self.respond_to?(m)
    if @@opts.has_key?(m)
      return true
    elsif m.to_s =~ /=$/ && @@opts.has_key?(m.to_s.chop.to_sym)
      return true
    else
      return super.method_missing(m, *args, &block)
    end  
  end
  
  def self.init
    parse_command_line
    puts "Command line parsed." if verbose
    
    puts "Initializing OAuth client" if verbose
    MageHand::Client.configure(CONSUMER_KEY, CONSUMER_SECRET)
    
    if directory_exists?
      puts "Loading saved configuration." if verbose
      saved_opts = YAML::load_file(CONFIG_FILE)
      @@opts.merge!(saved_opts.to_hash)
      puts "Configuration loaded" if verbose
    else
      puts "Saved configuration not found." if verbose
      create_directory
      puts "Created configuration directory." if verbose
    end
    @@client = MageHand::Client.new(nil, @@opts[:auth_token], @@opts[:auth_secret])
  end
  
  def self.save!
    saved_opts = {
      :auth_token => @@opts[:auth_token],
      :auth_secret => @@opts[:auth_secret]
    }
    File.open(CONFIG_FILE, 'w') do |file|
      file.puts(saved_opts.to_yaml)
    end  
  end
  
  def self.parse_command_line
    global_opts = Trollop::options do
      version "pre-alpha 0.0.1"
      banner "convert Obsidian Portal adventure logs into off-line formats."
      opt :verbose, "Act like the chatty gnome bard", :short => "-v"
      stop_on SUB_COMMANDS
    end

    @@requested_command = ARGV.shift # get the subcommand
    cmd_opts = case @@requested_command
      when "authorize" # parse delete options
        # no options here
      when "publish"  # parse copy options
        Trollop::options do
          opt :double, "Copy twice for safety's sake"
        end
      else
        # Trollop::die "unknown subcommand #{@@requested_command}"
      end
      
      @@opts.merge!(global_opts) if global_opts
      @@opts.merge!(cmd_opts) if cmd_opts
    # puts "Global options: #{global_opts.inspect}"
    # puts "Subcommand: #{cmd.inspect}"
    # puts "Subcommand options: #{cmd_opts.inspect}"
    # puts "Remaining arguments: #{ARGV.inspect}"
  end
  
  def self.client
    @@client
  end
  
  def self.requested_command
    @@requested_command
  end
  
  def self.directory_exists?
    File.exist?(CONFIG_DIRECTORY) && File.directory?(CONFIG_DIRECTORY)
  end
  
  def self.create_directory
    Dir.mkdir(CONFIG_DIRECTORY)
  end
end
