require 'test/unit'
require File.dirname(__FILE__) + '/../lib/tlv'

class TestTLV < Test::Unit::TestCase

  def setup
  end
  
  class TLVTest < TLV
    tag "00", "Test TLV"
    b   8,   "first field",  :first
    b   8,   "second field", :second
  end

  def test_basics
    t = TLVTest.new
    puts t.to_s
    assert true
  end 
end
