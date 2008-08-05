require 'test/unit'
require File.dirname(__FILE__) + '/../lib/tlv'

class TestTLV < Test::Unit::TestCase

  def setup
  end
  
  class TLVTest < TLV
    tlv "11", "Test TLV"
    b   8,   "first field",  :first
    b   8,   "second field", :second
  end

  class TLVTest2 < TLV
    tlv "32", "Test Rubify"
    b   8,   "My Test"
    b   8,   "Oh M@i!"
  end

  class TLVTest3 < TLV
    tlv "9F7F", "Test Raw"
    raw
  end

  def test_basics
    t = TLVTest.new
    t.first="\x01"
    t.second="\xAA"
    assert_equal "\x01", t.first
    assert_equal "\xaa", t.second
    assert_equal "\x11\x02\x01\xaa", t.to_b

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

  def test_parse_tag
    bytes = "\x01\x00\x00"
    tag, rest = TLV.get_tag bytes
    assert_equal "\x01", tag
    assert_equal "\x00\x00", rest

    bytes = "\xFF\x00\x00"
    tag, rest = TLV.get_tag bytes
    assert_equal "\xff\x00", tag
    assert_equal "\x00", rest


    bytes = "\xFF\x85\xAA"
    tag, rest = TLV.get_tag bytes
    assert_equal "\xff\x85\xaa", tag
    assert_equal "", rest
    
    bytes = "\x11\x02\x01\xaa"
    tag, rest = TLV.get_tag bytes
    assert_equal "\x11", tag
    assert_equal "\x02\x01\xaa", rest

  end
  def test_parse_length
    bytes = "\x03\x02"
    len, rest = TLV.get_length bytes
    assert_equal 3, len
    assert_equal "\x02", rest
    
    bytes = "\x81\x02\x11\x22"
    len, rest = TLV.get_length bytes
    assert_equal 2, len
    assert_equal "\x11\x22", rest


    bytes = "\x84\x00\x00\x00\x02\x11\x22"
    len, rest = TLV.get_length bytes
    assert_equal 2, len
    assert_equal "\x11\x22", rest


    bytes = "\x83\x00\x00\x02\x11\x22"
    len, rest = TLV.get_length bytes
    assert_equal 2, len
    assert_equal "\x11\x22", rest
    
    bytes = "\x82\x10\x01\x11\x22"
    len, rest = TLV.get_length bytes
    assert_equal 4097, len
    assert_equal "\x11\x22", rest
    
    bytes = "\x83\x00\x10\x01\x11\x22"
    len, rest = TLV.get_length bytes
    assert_equal 4097, len
    assert_equal "\x11\x22", rest
  end

  def test_parse
    t = TLVTest.new
    assert_equal "\x00", t.first
    t.first="\x01"
    t.second="\xAA"
    
    assert "\x01", t.first
    bytes = t.to_b
    t = TLV.parse bytes
    assert_equal TLVTest, t.class
    assert_equal "\x01", t.first
    assert_equal "\xAA", t.second
  end
  def test_rubify
    t = TLVTest2.new
    t.my_test = "\x01"
    assert_equal "\x01", t.my_test
    t.oh_mi = "\x02"
    assert_equal "\x02", t.oh_mi
  end
  def test_raw
    t = TLVTest3.new
    #puts t.methods.sort
    t.value= "bumsi"
    assert_equal "bumsi", t.value
    puts t
    bytes =  t.to_b
    t = TLV.parse bytes
    assert_equal "bumsi", t.value
    assert_equal TLVTest3, t.class
  end


end
