class TLV

  def self.parse bytes
    tag, rest = get_tag bytes
    length, rest = get_length rest
    impl = @tlv_classes[tag]
    impl.new bytes 
    
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

    if (len & 0x80) == 0x80 
      num_bytes = len & 0x0F
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
    return unless bytes
    tag, rest = TLV.get_tag(bytes)
    length, bytes = TLV.get_length(rest)

    fields.each { |field|
      bytes = field.parse(self, bytes, length)    
    } if fields

  end


end
