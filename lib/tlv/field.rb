class TLV
class Field
  attr_accessor :display_name, :name, :length
  def initialize clazz, desc, name=nil, len=0
    @length=len
    unless name
      name = desc.gsub(/\s/, "_")
      name = name.gsub(/\W/, "")
      name = name.downcase.to_sym
    end
    @name = name
    @display_name = desc
    define_accessor clazz
  end
  def parse tlv, bytes, length
    raise "not implemented! use subclass"
  end
  def define_accessor clazz
    raise "Not primitive: #{clazz.to_s}, TAG=#{TLV.b2s clazz.tag}" unless clazz.primitive?
  end
end
end
