# Simple lib to deconstruct tlv data
# TLV.parse str
# TLV.parse_hex str


module TLV
  def self.parse bytes, dictionary={}
    _dump(_parse(bytes), dictionary)
  end
  def self._parse bytes
    tlvs = []
    begin
      tlv, rest = _parse_tlv bytes
      tlvs << tlv
      bytes = rest
    end while rest && rest.length != 0
    tlvs
  end
  
  def self.parse_hex hex_str, dictionary={}
    self.parse s2b(hex_str), dictionary
  end

  def self._parse_tlv bytes
    tlv = TLV_Object.new
    tag, rest = TLV.get_tag bytes
    tlv.tag = tag
    len, rest = TLV.get_length rest
    tlv.length = len
    if (tag[0] & 0x20) != 0x00 # constructed object
      tlv.children = _parse rest[0,len]
    else
      tlv.value = rest[0,len]
    end
    [tlv, rest[len, rest.length]]
  end

  def self._dump (tlvs, dictionary, indent = "")
    dump = ""
    tlvs.each {|tlv|
      dump += "%s%-6s : %d" % [indent, "0x"+b2s(tlv.tag), tlv.length]
      if tlv.children
        dump += " ["+dictionary[tlv.tag]+"]" if (dictionary[tlv.tag])
        tlv.children.each {|child|
          dump += "\n"
          dump += _dump([child], dictionary, indent+"  ")
        }
      else
        dump += " : " + b2s(tlv.value) + "  (#{tlv.value})"
        dump += " ["+dictionary[tlv.tag]+"]" if (dictionary[tlv.tag])
      end
    }
    dump
  end
  class TLV_Object
    attr_accessor :tag, :length, :value, :children
  end
end

if $0 == __FILE__
  require "tlv"
  #puts TLV.parse_hex("9f7103313233")  
  puts TLV.parse_hex("32084102010243023456")  
  puts TLV.parse_hex("320841020102430234")
  dict = {"\x32" => "Test Tag", "\x41" => "Other Tag"}
  puts TLV.parse_hex("32084102010243023456", dict)
end

