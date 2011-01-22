#! /usr/local/bin/ruby

require 'rubygems'
require 'bundler/setup'

require 'mage-hand'
require 'OAuth' # Move this into mage-hand gem
include MageHand

require 'lib/configuration'

include Chronicler

Configuration.load

@mage_client = MageHand::Client.new

@request_token = @mage_client.consumer.get_request_token

puts "Put #{@request_token.authorize_url} in your browser"
print "Enter token: "
@auth_token = STDIN.readline.chomp
print "Enter secret: "
@auth_secret = STDIN.readline.chomp

Configuration.parameters[:auth_token] = @auth_token
Configuration.parameters[:auth_secret] = @auth_secret
Configuration.save
