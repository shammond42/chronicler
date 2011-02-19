require 'test/test_helper'

class ConfigurationTest < Test::Unit::TestCase
  def test_init
    Configuration.init
    
    assert true
  end
  
  context "The confuguration object" do
    should "create a hidden directory if it does not exist" do
      assert false
    end
  end
end