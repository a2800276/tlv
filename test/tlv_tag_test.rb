require 'test/unit'
require File.dirname(__FILE__) + '/../lib/tlv'

class TestTLVTag < Test::Unit::TestCase

  def setup
  end
  
  class TLVTest < TLV
    tlv "31", "Test TLV"
    b   8,   "first field",  :first
    b   8,   "second field", :second
  end

  def test_basics
    t = TLVTest.new
    0.upto(0x3f) {|i|
      TLVTest.tlv(("%02x"%i), "")
      assert TLVTest.universal?, i.to_s
      assert !TLVTest.application?, i.to_s
      assert !TLVTest.context_specific?, i.to_s
      assert !TLVTest.private?, i.to_s
    }
    0x40.upto(0x4f) {|i|
      TLVTest.tlv(("%02x"%i), "")
      assert !TLVTest.universal?, i.to_s
      assert TLVTest.application?, i.to_s
      assert !TLVTest.context_specific?, i.to_s
      assert !TLVTest.private?, i.to_s
    }
    0x80.upto(0xBf) {|i|
      TLVTest.tlv(("%02x"%i), "")
      assert !TLVTest.universal?, i.to_s
      assert !TLVTest.application?, i.to_s
      assert TLVTest.context_specific?, i.to_s
      assert !TLVTest.private?, i.to_s
    }
    0xC0.upto(0xFF) {|i|
      TLVTest.tlv(("%02x"%i), "")
      assert !TLVTest.universal?, i.to_s
      assert !TLVTest.application?, i.to_s
      assert !TLVTest.context_specific?, i.to_s
      assert TLVTest.private?, i.to_s
    }
    TLVTest.tlv "32", ""
    puts TLVTest.tag

  end 

end
