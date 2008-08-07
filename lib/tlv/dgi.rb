
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

  def get_len_bytes len
    bytes = case len
            when 0..0xfe : "" << len
            when 0xff..65534 : "\xff"+[len].pack("n")
            else
                    raise "Don't be silly"
            end
  end
end
