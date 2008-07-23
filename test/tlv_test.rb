require 'test/unit'
require File.dirname(__FILE__) + '/../lib/tlv'

class TestTLV < Test::Unit::TestCase

  def setup
  end
  
  class TLVTest < TLV
    
  end

  def test_class_meth
    bytes = "\123\234\345\456\123\321\012"
    h = Hexy.new bytes

    assert_equal h.to_s, Hexy.dump(bytes,{}) 

  end 
  def test_dump
        b = Hexy.new "abc"
        assert_equal %Q(0000000: 61 62 63                                           abc

), b.to_s

        b = Hexy.new "\000\001\003\005\037\012\011bcdefghijklmnopqrstuvwxyz0123456789"
        assert_equal %Q(0000000: 00 01 03 05 1f 0a 09 62   63 64 65 66 67 68 69 6a  .......b cdefghij 
0000010: 6b 6c 6d 6e 6f 70 71 72   73 74 75 76 77 78 79 7a  klmnopqr stuvwxyz 
0000020: 30 31 32 33 34 35 36 37   38 39                    01234567 89

), b.to_s
        
        
        b = Hexy.new("\000\001\003\005\037\012\011bcdefghijklmnopqrstuvwxyz0123456789", :numbering=>:hex_bytes, :width=> 8)
        assert_equal %Q(0000000: 00 01 03 05   1f 0a 09 62  .... ...b 
0000008: 63 64 65 66   67 68 69 6a  cdef ghij 
0000010: 6b 6c 6d 6e   6f 70 71 72  klmn opqr 
0000018: 73 74 75 76   77 78 79 7a  stuv wxyz 
0000020: 30 31 32 33   34 35 36 37  0123 4567 
0000028: 38 39                      89

), b.to_s
        
        
        
        
  end

  def test_numbering
    
        b = Hexy.new("\000\001\003\005\037\012\011bcdefghijklmnopqrstuvwxyz0123456789", :numbering=>:none, :format=>:fours)
        assert_equal %Q(0001 0305 1f0a 0962 6364 6566 6768 696a  .......b cdefghij \n6b6c 6d6e 6f70 7172 7374 7576 7778 797a  klmnopqr stuvwxyz \n3031 3233 3435 3637 3839                 01234567 89\n\n), b.to_s


        b = Hexy.new("\000\001\003\005\037\012\011bcdefghijklmnopqrstuvwxyz0123456789", :numbering=>:none, :width=>32)
        assert_equal %Q(00 01 03 05 1f 0a 09 62 63 64 65 66 67 68 69 6a   6b 6c 6d 6e 6f 70 71 72 73 74 75 76 77 78 79 7a  .......bcdefghij klmnopqrstuvwxyz \n30 31 32 33 34 35 36 37 38 39                                                                      0123456789\n\n), b.to_s

  end
  def test_format

        b = Hexy.new "\000\001\003\005\037\012\011bcdefghijklmnopqrstuvwxyz0123456789", :format=>:none
        assert_equal %Q(0000000: 000103051f0a0962636465666768696a .......b cdefghij 
0000010: 6b6c6d6e6f707172737475767778797a klmnopqr stuvwxyz 
0000020: 30313233343536373839             01234567 89

), b.to_s
        
        b = Hexy.new("\000\001\003\005\037\012\011bcdefghijklmnopqrstuvwxyz0123456789", :format=>:fours)
        assert_equal %Q(0000000: 0001 0305 1f0a 0962 6364 6566 6768 696a  .......b cdefghij 
0000010: 6b6c 6d6e 6f70 7172 7374 7576 7778 797a  klmnopqr stuvwxyz 
0000020: 3031 3233 3435 3637 3839                 01234567 89

), b.to_s

        b = Hexy.new("\000\001\003\005\037\012\011bcdefghijklmnopqrstuvwxyz0123456789", :numbering=>:hex_bytes, :width=>32, :format=>:fours)
        assert_equal %Q(0000000: 0001 0305 1f0a 0962 6364 6566 6768 696a 6b6c 6d6e 6f70 7172 7374 7576 7778 797a  .......bcdefghij klmnopqrstuvwxyz 
0000020: 3031 3233 3435 3637 3839                                                         0123456789

), b.to_s
  end

  def test_case

        b = Hexy.new("\000\001\003\005\037\012\011bcdefghijklmnopqrstuvwxyz0123456789", :numbering=>:none, :format=>:fours, :case=>:upper)
        assert_equal %Q(0001 0305 1F0A 0962 6364 6566 6768 696A  .......b cdefghij 
6B6C 6D6E 6F70 7172 7374 7576 7778 797A  klmnopqr stuvwxyz 
3031 3233 3435 3637 3839                 01234567 89

), b.to_s
  end

  def test_annotate

        b = Hexy.new "\000\001\003\005\037\012\011bcdefghijklmnopqrstuvwxyz0123456789", :annotate=>:none
        assert_equal %Q(0000000: 00 01 03 05 1f 0a 09 62   63 64 65 66 67 68 69 6a 
0000010: 6b 6c 6d 6e 6f 70 71 72   73 74 75 76 77 78 79 7a 
0000020: 30 31 32 33 34 35 36 37   38 39                   \n\n), b.to_s
  end
  def test_width

        b = Hexy.new("\000\001\003\005\037\012\011bcdefghijklmnopqrstuvwxyz0123456789", :numbering=>:hex_bytes, :width=> 8, :format=>:fours)
        assert_equal %Q(0000000: 0001 0305 1f0a 0962  .... ...b \n0000008: 6364 6566 6768 696a  cdef ghij \n0000010: 6b6c 6d6e 6f70 7172  klmn opqr \n0000018: 7374 7576 7778 797a  stuv wxyz \n0000020: 3031 3233 3435 3637  0123 4567 \n0000028: 3839                 89\n\n), b.to_s

        b = Hexy.new("\000\001\003\005\037\012\011bcdefghijklmnopqrstuvwxyz0123456789", :numbering=>:none, :width=>8)
        assert_equal %Q(00 01 03 05   1f 0a 09 62  .... ...b \n63 64 65 66   67 68 69 6a  cdef ghij \n6b 6c 6d 6e   6f 70 71 72  klmn opqr \n73 74 75 76   77 78 79 7a  stuv wxyz \n30 31 32 33   34 35 36 37  0123 4567 \n38 39                      89\n\n), b.to_s

        b = Hexy.new("\000\001\003\005\037\012\011bcdefghijklmnopqrstuvwxyz0123456789", :numbering=>:hex_bytes, :width=>32)
        assert_equal %Q(0000000: 00 01 03 05 1f 0a 09 62 63 64 65 66 67 68 69 6a   6b 6c 6d 6e 6f 70 71 72 73 74 75 76 77 78 79 7a  .......bcdefghij klmnopqrstuvwxyz \n0000020: 30 31 32 33 34 35 36 37 38 39                                                                      0123456789\n\n), b.to_s
  end
end
