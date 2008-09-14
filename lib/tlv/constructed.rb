class TLV
  class << self
    
    def mand_tags
      @mand_tags ||= (self == TLV ? [] : superclass.mand_tags.dup)
    end
    def opt_tags
      @opt_tags ||= (self == TLV ? [] : superclass.opt_tags.dup)
    end

    #    Takes either a subclass of TLV or the following options, which are used to
    #    create an subclass.
    #    Options:
    #      :tag
    #      :display_name
    #
    #      :classname (will be derived from display_name if not given)
    #      :accessor_name (will be derived from display_name if not given)
    def mandatory tlv, accessor_name=nil
      handle_subtag mand_tags, tlv, accessor_name
    end

    # for constructed tlv's, add subtags that may be present
    def optional tlv, accessor_name=nil
      handle_subtag opt_tags, tlv, accessor_name
    end
    
    def register tlv
      @tlv_classes ||= {}
      warn "tag #{TLV.b2s(tlv.tag)} already defined!" if @tlv_classes[tlv.tag]
      @tlv_classes[tlv.tag] = tlv
    end

    def lookup tag
      return self if tag == self.tag
      @tlv_classes ||= {}
      tlv = @tlv_classes[tag]
      if !tlv && ! (self == TLV)
        warn "looking up tag #{TLV.b2s(tag)} in super!"
        raise "bla"
        tlv ||= super
      end
      tlv
    end

    # internal, common functionality for mndatory and optional
    def handle_subtag arr, tlv, accessor_name
      tlv = handle_options(tlv) if tlv.is_a? Hash
      raise "#{tlv} must be a subclass of TLV!" unless tlv.ancestors.include? TLV
      if accessor_name
        tlv= tlv.dup
        tlv.accessor_name= accessor_name
      end
      define_accessor(tlv)
      
      register(tlv)
      arr << tlv
    end

    def handle_options options
      tag = options[:tag]
      display_name = options[:display_name]
      classname = options[:classname] || rubify_c(display_name)
      new_class = self.const_set(classname, Class.new(TLV))
      new_class.tlv(tag, display_name, options[:accessor_name])
      new_class.raw
      new_class
    end

    def rubify_a display
      name = display.gsub(/\s+/, "_")
      name = name.downcase.to_sym
    end

    def rubify_c display
      name = display.gsub(/\s+/, "")
    end
    
    def define_accessor tlv_class
      s = tlv_class
      # check we are actually creating an accessor for an TLV
      while s = s.superclass
        break if s == TLV
      end      
      raise "not a TLV class!" unless s

      # determine the accessor name
      # currently the call graph of this method ensures the class 
      # will have an accessor name.
      name = tlv_class.accessor_name
      
      define_method("#{name}="){ |val|
        # must either be an instance of tlv_val
        # or a raw value.
        if val.is_a? TLV
          self.instance_variable_set("@#{name}", val)
        else
          v = tlv_class.new
          # _should_ be a String, but we'll bang anything 
          # into value for now...
          v.value = val.to_s
          self.instance_variable_set("@#{name}", v)
        end 
      }

      define_method("#{name}") {
        self.instance_variable_get("@#{name}") 
      }

    end

  end

end

