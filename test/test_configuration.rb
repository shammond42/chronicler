require 'lib/configuration'
require 'test/unit'

class ConfigurationTest < Test::Unit::TestCase
  def test_init
    Configuration.init
    
    assert true
  end
end