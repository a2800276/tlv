

class TLV

  def self.register tag, clazz
    @tlv_classes ||= {}
    @tlv_classes[tag] = clazz
  end

  def self.b2s bytestr
    r = bytestr.unpack("H*")[0]
    r.length > 1 ? r : "  "
  end
  def self.s2b string
    string = string.gsub(/\s+/, "")
    [string].pack("H*") 
  end


  class Field
    attr_accessor :display_name, :name, :length
    def initialize len, desc, name
      @length=len
      @name = name
      @display_name = desc
    end
    def parse tlv, bytes
      raise "not implemented! use subclass"
    end
  end
#
#  class A < Field
#  end
#
#  class AN < Field
#  end
#
#  class ANS < Field
#  end
#
 #
#  class CN < Field
#  end
#
#  class N < Field
#  end
  
  class << self
    attr_accessor :tag
    attr_accessor :description
    def tlv tag, description
      @tag = TLV.s2b(tag)
      @description = description
      TLV.register @tag, self
    end
    def fields
      @fields ||= (self == TLV ? [] : superclass.fields.dup) 
    end

    def b len, desc, name
      raise "invalid len #{len}" unless (len%8 == 0)
      field = B.new(len, desc, name)
      field.define_accessor(self)
      fields << B.new(len, desc, name)
      
    end
  end

  def to_s
    longest = 0
    fields.each { |field|
      longest = field.display_name.length if field.display_name.length > longest
    }
    fmt = "%#{longest}s : %s\n"
    str = "#{self.class.description}"
    str = " (0x#{TLV.b2s(tag)})\n" if tag
    str << "\n"

    str << "-" * (str.length-1) << "\n"
    fields.each { |field|
      str << (fmt % [field.display_name, TLV.b2s(self.send(field.name))])
    }
    str
  end

  def to_b
    bytes = ""
    fields.each { |field|
      bytes << self.send(field.name)
    }

    raise "not yet implemented" if bytes.length > 255
    bytes.insert 0, [bytes.length].pack("C*")
    bytes.insert 0, tag
  end

  def fields
    self.class.fields
  end

  def tag
    self.class.tag
  end
end


