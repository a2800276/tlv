# Simple lib to deconstruct tlv data
# TLV.parse str
# TLV.parse_hex str
require 'hexy'

module TLV
  def self.parse bytes, dictionary={}
    _dump(_parse(bytes), dictionary)
  end
  def self.parse_hex hex_str, dictionary={}
    self.parse s2b(hex_str), dictionary
  end

  def self.parse_dgi bytes, dictionary={}
    _dump(_parse_dgi(bytes), dictionary) 
  end
  
  def self.parse_dgi_hex hex_str, dictionary={}
    self.parse_dgi s2b(hex_str), dictionary
  end
  def self.printable? bytes
    count = 0
    count_printable = 0
    bytes.each_byte {|b|
      count += 1
      count_printable += 1 if b > 31
    }
    return (count_printable.to_f/count) > 0.90
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

  def self._parse_dgi bytes
    dgis = []
    begin
      dgi = TLV_Object.new
      tag, rest    = DGI.get_tag bytes
      dgi.tag      = tag
      len, rest    = DGI.get_length rest
      dgi.length   = len
      dgi.children = _parse rest[0,len]
      dgis << dgi
      bytes = rest[len, rest.length]
    end while bytes && bytes.length != 0
    dgis
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
        dump += "\n"
        tlv.children.each {|child|
          dump += _dump([child], dictionary, indent+"  ")
        }
      else
        if (tlv.value.length < 17)
          dump += " : " + b2s(tlv.value) 
          dump += "  (#{tlv.value})" if printable?(tlv.value)
          dump += " ["+dictionary[tlv.tag]+"]" if (dictionary[tlv.tag])
        else
          dump += " ["+dictionary[tlv.tag]+"]" if (dictionary[tlv.tag])
          dump +="\n"
          dump += Hexy.dump(tlv.value, :indent=>indent.length+2)
        end

        dump += "\n"
      end
    }
    #puts ">>>>"
    #puts dump
    #puts "<<<<"
    dump
  end
  class TLV_Object
    attr_accessor :tag, :length, :value, :children
  end
end

if $0 == __FILE__
  require "tlv"
#  puts TLV.parse_hex("9f7103313233")  
#  puts
#  puts TLV.parse_hex("32084102010243023456")  
#  puts
#  puts TLV.parse_hex("320841020102430234")
#  puts
#  dict = {"\x32" => "Test Tag", "\x41" => "Other Tag"}
#  puts TLV.parse_hex("32084102010243023456", dict)
#  puts
#  puts TLV.parse_hex("320841020102430234569f7103313233", dict)
#  puts
  dict = {"\x57" => "Track 2 Equivalent Data",
          "\x70" => "READ RECORD Response Message Template"}
  puts TLV.parse_dgi_hex("010142704057134451973022158124D12102011089573110000F5F201A4D55535445524D414E4E2F4D41582020202020202020202020209F1F0B0102030405060708090A0B")
  puts
  puts TLV.parse_dgi_hex("010142704057134451973022158124D12102011089573110000F5F201A4D55535445524D414E4E2F4D41582020202020202020202020209F1F0B0102030405060708090A0B02018670818390818047D56F644D05FF41180926D965765BBC1894E6F973FA6DD56FC69313E82E9480F3405D7A4056B3AB5F31293D22F55A460D540E954BCF74E3D056DA839E756D1C6AC4BAD76D2747E158288BDE28CEEB321C930ED2F40ED35884304DD3D69E87BBC81FBEE22ACD2F0851A5DCA6DAAC794E633A70072AF5B93103C115B225118B77 ", dict)
end

