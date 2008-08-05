class TLV

class << self
  CLASS_MASK      = 0xC0
  UNIVERSAL_CLASS = 0x00 
  APPLICATION     = 0x40 
  CTX_SPECIFIC    = 0x80 
  PRIVATE         = 0xC0 

  BYTE6           = 0x20

  def universal?
    ((@tag & CLASS_MASK) == UNIVERSAL_CLASS) if @tag
  end
  def application?
    ((@tag & CLASS_MASK) == APPLICATION) if @tag
  end
  def context_specific?
    ((@tag & CLASS_MASK) == CTX_SPECIFIC) if @tag
  end
  def private?
    ((@tag & CLASS_MASK) == PRIVATE) if @tag
  end
  def primitive?
    if @tag
      ((@tag & BYTE6) == 0x00) 
    else
      true # `tagless` datastructs are by default primitive
    end
  end
  def constructed?
    ((@tag & BYTE6) == BYTE6) if @tag
  end
  # check the tag is approriate length
  def check_tag
    if (tag & 0x1f) == 0x1f # last 5 bits set, 2 byte tag
      raise "Tag too short: #{b2s(tag)} should be 2 bytes" unless tag.length > 1
      if (tag[1]&0x80) == 0x80
        raise "Tag length incorrect: #{b2s(tag)} should be 3 bytes" unless tag.length == 3
      else
        raise "Tag too long: #{b2s(tag)} should be 2 bytes" if tag.length > 2
      end
    else
      raise "Tag too long: #{b2s(tag)} should be 1 bytes" if tag.length > 1
    end
  end

end        
end
