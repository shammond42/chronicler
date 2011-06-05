class Chronicle < Thor
  require 'rubygems'
  require 'bundler/setup'

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
  require 'lib/fate'
  require 'lib/helpers'
  require 'lib/section'
  require 'lib/couchbook'
  require 'lib/view_helpers'
  require 'lib/title_page'
  
  require_all 'config'
  
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