class TLV
  class Raw < Field
    def initialize clazz, desc=nil, name=nil, len=0
      desc ||= "Value" 
      super
    end
    def define_accessor clazz
      name = @name
      clazz.instance_eval{
        define_method("#{name}="){|val|
          val ||= ""
          raise("must be a String #{val}")  unless val.is_a?(String)
          self.instance_variable_set("@#{name}", val)
        }
        
        define_method("#{name}") {
          self.instance_variable_get("@#{name}") || ""
        }
      }
    end
    def parse tlv, bytes, length
      val  = bytes[0, length]
      rest = bytes[length, bytes.length]
      tlv.send("#{name}=", val)
      rest
    end 
  end
end
