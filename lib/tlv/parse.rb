class TLV
  # return [tlv, rest], the parsed TLV and any leftover bytes.
  def self.parse bytes
    return nil unless bytes && bytes.length>0
    tag, rest = get_tag bytes
    length, rest = get_length rest
    impl = @tlv_classes[tag]
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
      length, bytes = TLV.get_length(rest)
    end
    if self.class.primitive?
      fields.each { |field|
        bytes = field.parse(self, bytes, length)    
      } if fields
    else
      while bytes
        tlv, bytes = TLV.parse bytes 
        begin

        self.send("#{tlv.class.accessor_name}=", tlv)  
        rescue
          puts $!
          puts tlv.class
          puts tlv.methods.sort
        end
      end
    end

    bytes

  end


end
