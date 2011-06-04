class Thor
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
  
  require 'lib/ob_port'
  require 'lib/fate'
  require 'lib/helpers'
  require 'lib/section'
  require 'lib/couchbook'
  require 'lib/view_helpers'
  require 'lib/title_page'
  
  require_all 'config'
end