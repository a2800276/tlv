require 'test/unit'
require File.dirname(__FILE__) + '/../lib/tlv'

class TestTLVConstructed < Test::Unit::TestCase

  def setup
  end
  
  class TLVTagTest < TLV
    tlv "31", "Test TLV"
    b   8,   "first field",  :first
    b   8,   "second field", :second
  end
  class TLVTestCons < TLV
    tlv "32", "Test Constructed"
    mandatory TLVTagTest, "tlv_tag_test"
    mandatory :tag => "33",
              :display_name => "Another Test"
  end

  class TLVTestCons2 < TLV
    tlv "32", "Test Constructed"
    optional TLVTagTest, "tlv_tag_test"
    optional :tag => "33",
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
    
    assert_equal(TLV.s2b("32083102010233023456"), t3.to_b)
  end 
  

end
