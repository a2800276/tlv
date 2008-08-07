

class TLV
 class B < Field
    def define_accessor clazz
      super
      name = @name
      len  = @length 
      clazz.instance_eval{
        define_method("#{name}="){|val|
          raise("invalid value nil")        unless val
          raise("must be a String #{val}")  unless val.is_a?(String)
          raise("incorrect length: #{val}") unless (val.length*8) <= len
          self.instance_variable_set("@#{name}", val)
        }
        
        define_method("#{name}") {
          self.instance_variable_get("@#{name}") || "\x00" * (len/8) 
        }
      }
    end

    def parse tlv, bytes, _len
      val  = bytes[0, length/8]
      rest = bytes[length/8, bytes.length]
      # check val...
      tlv.send("#{name}=", val)
      rest 
    end
  end
end
