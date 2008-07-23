

class TLV

  def register tag, clazz

  end
  class Field
    attr_accessor :desc, :name, :length
    def initialize len, desc, name

    end
  end
  class A < Field
  end
  class AN < Field
  end
  class ANS < Field
  end
  class B < Field
  end
  class CN < Field
  end
  class N < Field
  end
  
  self << class
    def tag tag, description
      TLV.register tag, self
    end
    def fields
      @fields ||= (self == TLV ? [] : superclass.fields.dup) 
    end

    def b len, desc, name
      raise "invalid len #{len}" unless (len%8 == 0)
      fields << B.new(len, desc, name)
      define_method("#{name=}"){|val|
        raise "invalid value nil" unless val
        raise "must be a String #{val}" unless val.is_a? String
        raise "incorrect length: #{val}" unless val.length*8 <= len
        self.instance_variable_set("@#{name}", val)
      }
      define_method("#{name}") {
        self.instance_variable_get("@#{name}") || "\x00" * (len/8) 
      }
    end
  end

  def to_s
    longest = 0
    self.class.fields.each { |field|
      longest = field.desc.length if field.desc.length > longest
    }
    fmt = "%#{longest}s : %s\n"
    str = ""
    self.class.fields.each { |field|
      
    }
  end

  def to_b
    
  end
end

class CPLC < TLV
  tag       "9F7F", "Card Production Lifecycle"
  b         16,     "IC Fabricator",                        :ic_fab
  b         16,     "IC Type",                              :ic_type
  b         16,     "OS Identifier",                        :os_id
  b         16,     "OS Release Date",                      :os_rel_date
  b         16,     "OS Release Level",                     :os_release_level
  b         16,     "IC Fabrication Date",                  :ic_fab_date
  b         32,     "IC Serial Number",                     :ic_serial_number
  b         16,     "IC Batch Identifier",                  :ic_batch_identifier
  b         16,     "IC Module Fabricator",                 :ic_module_fabricator
  b         16,     "IC Module Packaging Date",             :ic_module_pack_date
  b         16,     "ICC Manufacturer",                     :icc_manufacturer
  b         16,     "IC Embedding Date",                    :ic_embedding_date
  b         16,     "IC Prepresonalizer",                   :ic_prepersonlizer
  b         16,     "IC Pre-Personalization Date",          :ic_pre_pers_date
  b         32,     "IC Pre-Personalization Equipment ID",  :ic_pre_pers_equip_id       
  b         16,     "IC Personalizer",                      :ic_personalizer
  b         16,     "IC Personalization Date",              :ic_pers_date
  b         32,     "IC Personalization Equipment ID",      :ic_pers_equip_id   
end
