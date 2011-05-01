class Thor
  require 'rubygems'
  require 'bundler/setup'

  require 'net/http'
  require 'uri'

  require 'eeepub'
  require 'couchrest'
  require 'nokogiri'
  
  require 'lib/fate'
  require 'lib/helpers'
  require 'lib/section'
  require 'lib/book'
  include Fate
end