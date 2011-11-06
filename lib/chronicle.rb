class Chronicle < Thor
  require 'rubygems'
  require 'bundler/setup'

  require 'ruby-debug'
  
  require 'require_all'
  require 'net/http'
  require 'uri'
  require 'active_support/hash_with_indifferent_access'
  
  require 'eeepub'
  require 'couchrest'
  require 'nokogiri'
  require 'mustache'
  require 'mage-hand'
  include MageHand

  # TODO: Turn this into a require_all once obsolete files are refactored out
  # of the lib directory.
  require 'lib/ob_port'
  require 'lib/ice_dragon_wiki'
  require 'lib/fate'
  require 'lib/section'
  require 'lib/couchbook'
  require 'lib/view_helpers'
  require 'lib/title_page'
  
  require_all 'lib/epub'
  require_all 'config'
  
  # Utility wide thor options
  class_option :verbose, :type => :boolean, :default => false,
    :desc => 'give detailed descriptions of what is happening.'
    
  def initialize(*args)
    super
    load_configuration
    ObjectSpace.define_finalizer(self, self.class.method(:finalize).to_proc)
  end
  
  def self.finalize(id)
    Configuration.save_configuration
    puts "Saved authorization information." if config[:verbose]
  end
end