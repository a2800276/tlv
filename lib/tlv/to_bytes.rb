class TLV
  
  def get_bytes
    if self.class.primitive?  || (self.is_a?(DGI) && fields.length!=0)
      bytes = get_bytes_primitive
    else
      bytes = get_bytes_constructed
    end
  end      
  def get_bytes_primitive
    bytes = ""
    fields.each { |field|
      bytes << self.send(field.name)
    }
    bytes
  end

  def get_bytes_constructed
    bytes = ""
    mandatory.each {|t|
      tlv = self.send(t.accessor_name)
      raise "Mandatory subtag #{t} not set!" unless tlv
      bytes << tlv.to_b
    }
    optional.each { |t|
      tlv = self.send(t.accessor_name)
      bytes << tlv.to_b if tlv
    }
    bytes
  end

  def get_len_bytes len

    # one byte max = 127
    # two          = 255 (2**8)-1
    # three        = 65535 (2 ** 16) -1
    # four         = 16777215 (2 ** 32) -1
    num_len_bytes = case len
                    when 0..127            : 1
                    when 128..255          : 2
                    when 256..65535        : 3 # short        
                    when 65536..4294967295 : 5 # long, skip 3 byte len, too difficult :)
                    else
                            raise "Don't be silly"
                    end
    len_bytes     = case num_len_bytes
                    when 1 : "" << len
                    when 2 : "\x81" << len 
                    when 3 : "\x82" << [len].pack("n")
                    when 5 : "\x84" << [len].pack("N") 
                    else
                      raise "Can't happen"
                    end      
    return len_bytes 
  end

  def to_b
    bytes = get_bytes
    if tag
      bytes.insert 0, get_len_bytes(bytes.length)
      bytes.insert 0, tag
    end
    bytes
  end
end
