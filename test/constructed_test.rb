require 'test/unit'
require File.dirname(__FILE__) + '/../lib/tlv'

class TestTLVConstructed < Test::Unit::TestCase

  def setup
  end
  
  class TLVTagTest < TLV
    tlv "41", "Test TLV"
    b   8,   "first field",  :first
    b   8,   "second field", :second
  end
  class TLVTestCons < TLV
    tlv "32", "Test Constructed" 
    mandatory TLVTagTest, "tlv_tag_test"
    mandatory :tag => "43",
              :display_name => "Another Test"
  end

  class TLVTestCons2 < TLV
    tlv "32", "Test Constructed 32 2"
    optional TLVTagTest, "tlv_tag_test"
    optional :tag => "43",
             :display_name => "Another Test"
  end

  class DGITest < DGI
    tlv "9102", "Random Test Data"
    mandatory TLVTagTest, :test
    optional :tag => "43",
             :display_name => "Another Test"
  end

  def basics t
    assert(t.methods.include?("tlv_tag_test" ))
    assert(t.methods.include?("tlv_tag_test="))
    assert(t.methods.include?("another_test" ))
    assert(t.methods.include?("another_test="))
  end
  def test_basics
    t = TLVTestCons.new
    basics t
    assert_nothing_raised {
      t = TLVTestCons::AnotherTest.new 
    }
    t = TLVTestCons2.new
    basics t
    assert_nothing_raised {
      t = TLVTestCons2::AnotherTest.new 
    }
  end
 
  def test_const_to_b
    t = TLVTagTest.new
    t.first  = "\x01"
    t.second = "\x02"

    t2 = TLVTestCons::AnotherTest.new
    t2.value = "\x34\x56"

    t3 = TLVTestCons.new
    t3.tlv_tag_test= t
    t3.another_test= t2
    
    assert_equal(TLV.s2b("32084102010243023456"), t3.to_b)

    bytes = t3.to_b
    t, rest = TLVTestCons._parse bytes*2
    assert_equal bytes, rest
    assert_equal "\x01", t.tlv_tag_test.first
    assert_equal "\x02", t.tlv_tag_test.second
    assert_equal "\x34\x56", t.another_test.value

    t, rest = TLV._parse rest
    assert_equal "\x01", t.tlv_tag_test.first
    assert_equal "\x02", t.tlv_tag_test.second
    assert_equal "\x34\x56", t.another_test.value
  end 

  def test_const_direct_value
    t = TLVTagTest.new
    t.first  = "\x01"
    t.second = "\x02"
    
    t2 = TLVTestCons.new
    t2.tlv_tag_test=t
    t2.another_test="\x34\x56"
    
    assert_equal(TLV.s2b("32084102010243023456"), t2.to_b)

  end

  def test_const_dgi
    te  = TLVTagTest.new
    te.first=  "\x01"
    te.second= "\x02"
    dgi = DGITest.new
    dgi.test= te
    dgi.another_test="\x34\x56"

    assert_equal(TLV.s2b("9102084102010243023456"), dgi.to_b)
  end
  

end
