require 'test/unit'
require File.dirname(__FILE__) + '/../lib/tlv'

class TestTLVTag < Test::Unit::TestCase

  def setup
  end
  
  class TLVTagTest < TLV
    tlv "41", "Test TLV"
    b   8,   "first field",  :first
    b   8,   "second field", :second
  end
  class TLVTestNoTag < TLV
    b   8,   "first field",  :first
    b   8,   "second field", :second
  end

  def test_basics
    t = TLVTagTest.new
    0.upto(0x3f) {|i|
      next if (i & 0x1f) ==0x1f # two byte tags
      TLVTagTest.tlv(("%02x"%i), "a")
      assert TLVTagTest.universal?, i.to_s
      assert !TLVTagTest.application?, i.to_s
      assert !TLVTagTest.context_specific?, i.to_s
      assert !TLVTagTest.private?, i.to_s
    }
    0x40.upto(0x4f) {|i|
      TLVTagTest.tlv(("%02x"%i), "b")
      assert !TLVTagTest.universal?, i.to_s
      assert TLVTagTest.application?, i.to_s
      assert !TLVTagTest.context_specific?, i.to_s
      assert !TLVTagTest.private?, i.to_s
    }
    0x80.upto(0xBf) {|i|
      next if (i & 0x1f) ==0x1f # two byte tags
      TLVTagTest.tlv(("%02x"%i), "c")
      assert !TLVTagTest.universal?, i.to_s
      assert !TLVTagTest.application?, i.to_s
      assert TLVTagTest.context_specific?, i.to_s
      assert !TLVTagTest.private?, i.to_s
    }
    0xC0.upto(0xFF) {|i|
      next if (i & 0x1f) ==0x1f # two byte tags
      TLVTagTest.tlv(("%02x"%i), "d")
      assert !TLVTagTest.universal?, i.to_s
      assert !TLVTagTest.application?, i.to_s
      assert !TLVTagTest.context_specific?, i.to_s
      assert TLVTagTest.private?, i.to_s
    }


  end 
  
  def test_invalid_tag
    
    assert_raise (RuntimeError) {

      TLVTagTest.tlv "9F", ""
    }
    assert_raise (RuntimeError) {
      TLVTagTest.tlv "9F0000", ""
    }
    assert_raise (RuntimeError) {
      TLVTagTest.tlv "9FF0", ""
    }
    assert_raise (RuntimeError) {
      TLVTagTest.tlv "9FF00000", ""
    }
    assert_raise (RuntimeError) {
      TLVTagTest.tlv "9FF0F000", ""
    }
    assert_raise (RuntimeError) {
      TLVTagTest.tlv "0000", ""
    }
  end

  def test_no_tag
    t = TLVTestNoTag.new
    assert !TLVTestNoTag.universal?
    assert !TLVTestNoTag.application?
    assert !TLVTestNoTag.context_specific?
    assert !TLVTestNoTag.private?
    assert TLVTestNoTag.primitive?
  end

end
