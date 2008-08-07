class TLV
  # return [tlv, rest], the parsed TLV and any leftover bytes.
  def self.parse bytes
    return nil unless bytes && bytes.length>0
    tag, _ = self.get_tag bytes
    impl = lookup(tag)
    tlv = impl.new 
    rest = tlv.parse(bytes)
    [tlv, rest]
  end

  def self.get_tag bytes
    tag = (bytes[0,1])
    if (tag[0] & 0x1f) == 0x1f # last 5 bits set, 2 byte tag
      tag = bytes[0,2]
      if (tag[1] & 0x80) == 0x80 # bit 8 set -> 3 byte tag
        tag = bytes[0,3]
      end
    end
    [tag, bytes[tag.length, bytes.length]]
  end

  def self.get_length bytes
    len = bytes[0,1][0]
    num_bytes=0

    if (len & 0x80) == 0x80     # if MSB set 
      num_bytes = len & 0x0F    # 4 LSB are num bytes total
      raise "Don't be silly" if num_bytes > 4
      len = bytes[1,num_bytes]
      len = ("#{"\x00"*(4-num_bytes)}%s" % len).unpack("N")[0]
    end
    # this will return ALL the rest, not just `len` bytes of the rest. Does this make sense?
    rest = bytes[1+num_bytes, bytes.length]
    # TODO handle errors...
    # warn if rest.length > length || rest.length < length ?
    [len, rest]
  end

  def initialize bytes=nil
    parse(bytes) if bytes
  end

  # returns the leftover bytes
  def parse bytes
    if tag
      tag, rest = TLV.get_tag(bytes)
      length, bytes = self.class.get_length(rest)
    end
    
    if self.class.primitive?
      bytes = parse_fields bytes, length
    else
      bytes = parse_tlv bytes, length
    end

    bytes

  end

  def parse_tlv bytes, length
    b = bytes[0,length]
    rest = bytes[length, bytes.length]

    while b && b.length != 0
      tlv, b = self.class.parse(b)
      self.send("#{tlv.class.accessor_name}=", tlv)
    end

    rest
  end
  def parse_fields bytes, length
    fields.each { |field|
      bytes = field.parse(self, bytes, length)    
    } if fields
    bytes
  end


end
