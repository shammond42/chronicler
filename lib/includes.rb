require 'rubygems'
require 'bundler/setup'

require 'mage-hand'

require 'lib/configuration'
require 'lib/authorize'
require 'lib/publish'
require 'lib/helpers'

include MageHand
include Chronicler