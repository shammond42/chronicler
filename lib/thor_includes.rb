class Thor
  require 'rubygems'
  require 'bundler/setup'

  require 'net/http'
  require 'uri'

  require 'eeepub'
  require 'couchrest'
  require 'nokogiri'
  require 'mustache'
  
  require 'lib/fate'
  require 'lib/helpers'
  require 'lib/section'
  require 'lib/couchbook'
  
  require 'config/mustache'
  
  include Fate
end