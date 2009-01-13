
class DGI < TLV

  def self.get_length(bytes)
    len = bytes[0]  #CPS 2.2 Creation of ...
    if len == 0xFF
      len = bytes[1,2].unpack("n")[0] 
    end
    num = len > 0xfe ? 3 : 1
    rest = bytes [num, bytes.length]
    [len, rest]
  end

  def self.check_tag 
    raise "incorrect tag length, dgi must be 2 : #{tag}" unless tag.length==2
  end

  def self.get_tag bytes
    tag = bytes[0,2]
    rest = bytes [2,bytes.length]
    [tag, rest]
  end

  def get_len_bytes len
    bytes = case len
            when 0..0xfe : "" << len
            when 0xff..65534 : "\xff"+[len].pack("n")
            else
                    raise "Don't be silly"
            end
  end

  class << self
    
    def primitive?
      false
    end
  end 
end
