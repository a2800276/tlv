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
    t.first="\x01"
    t.second="\xAA"
    assert_equal "\x01", t.first
    assert_equal "\xaa", t.second
    assert_equal "\x01\xaa", t.to_b

    assert_raise(RuntimeError) {
      t.first="\x02\x03"
    }
    assert_raise(RuntimeError) {
      t.first=Time.new
    }
    assert_raise(RuntimeError) {
      t.second=1
    }
    puts t.to_s
    assert true
  end 
end
