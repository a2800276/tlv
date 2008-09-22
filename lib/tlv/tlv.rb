

class TLV 

#  def self.register tag, clazz
#    @tlv_classes ||= {}
#    @tlv_classes[tag] = clazz
#  end

  def self.b2s bytestr
    r = bytestr.unpack("H*")[0]
    r.length > 1 ? r : "  "
  end
  def self.s2b string
    string = string.gsub(/\s+/, "")
    [string].pack("H*") 
  end
  
  DEBUG = ENV["DEBUG"] 

  # Outputs a warning in case the enironment
  # variable `DEBUG` is set.
  def self.warn mes
    STDERR.puts "[warn] #{mes}" if ENV["DEBUG"]
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
    attr_accessor :display_name
    # If this TLV is placed into another as a subfield, this will be 
    # the name of the accessor, default is the rubyfied display_name
    attr_accessor :accessor_name
    def tlv tag, display_name, accessor_name=nil
      @tag = TLV.s2b(tag)
      def @tag.& flag
        self[0] & flag
      end
      check_tag
      @display_name = display_name
      @accessor_name = accessor_name || rubify_a(display_name)
      TLV.register self
    end
    
    

    def fields
      @fields ||= (self == TLV ? [] : superclass.fields.dup) 
    end

    def b len, desc, name=nil
      raise "invalid len #{len}" unless (len%8 == 0)
      fields << B.new(self, desc, name, len)
    end
    
    def raw desc=nil, name=nil
      fields << Raw.new(self, desc, name)
    end

    # for constructed tlv's, add subtags that must be present
  end # meta class thingie

  def display_name
     self.class.display_name
  end
  def to_s
    longest = 0
    fields.each { |field|
      longest = field.display_name.length if field.display_name.length > longest
    }
    fmt = "%#{longest}s : %s\n"
    str = "#{display_name}"
    str << " (0x#{TLV.b2s(tag)})" if tag
    str << "\n"

    str << "-" * (str.length-1) << "\n"
    fields.each { |field|
      str << (fmt % [field.display_name, TLV.b2s(self.send(field.name))])
    }
    (mandatory+optional).each { |tlv_class|
      temp_tlv = self.send(tlv_class.accessor_name)
      temp = temp_tlv.to_s
      temp.gsub!(/^/, "  ")
      str << temp
    }
    str
  end


  def fields
    self.class.fields
  end

  def mandatory
    self.class.mand_tags
  end
  def optional
    self.class.opt_tags
  end

  def tag
    self.class.tag
  end
end


