#universal numbers, source http://en.wikipedia.org/wiki/Basic_Encoding_Rules
#
TLV::UNIVERSAL = [
['EOC (End-of-Content)',"P",0x00],
['BOOLEAN',"P",0x01],
['INTEGER',"P",0x02],
['BIT STRING',"P/C",0x03],
['OCTET STRING',"P/C",0x04],
['NULL',"P",0x05],
['OBJECT IDENTIFIER',"P",0x06],
['Object Descriptor',"P",0x07],
['EXTERNAL',"C",0x08],
['REAL (float)',"P",0x09],
['ENUMERATED',"P",0x0A],
['EMBEDDED PDV',"C",0x0B],
['UTF8String',"P/C",0x0C],
['RELATIVE-OID',"P",0x0D],
['SEQUENCE and SEQUENCE OF',"C",0x10],
['SET and SET OF',"C",0x11],
['NumericString',"P/C",0x12],
['PrintableString',"P/C",0x13],
['T61String',"P/C",0x14],
['VideotexString',"P/C",0x15],
['IA5String',"P/C",0x16],
['UTCTime',"P/C",0x17],
['GeneralizedTime',"P/C",0x18],
['GraphicString',"P/C",0x19],
['VisibleString',"P/C",0x1A],
['GeneralString',"P/C",0x1B],
['UniversalString',"P/C",0x1C],
['CHARACTER STRING',"P/C",0x1D],
['BMPString',"P/C",0x1E],
]

def make_dict
  def add_primitive e,d
    tag = ("" <<  e[2])
    d[tag] = e[0]
  end
  def add_const e,d
    tag = "" << (e[2] | 0x20)
    d[tag] = e[0]
  end
  dict = {}
  TLV::UNIVERSAL.each {|entry|
    case entry[1]
    when "P"
      add_primitive entry, dict
    when "C"
      add_const entry, dict
    when "P/C"
      add_primitive entry, dict
      add_const entry, dict
    end
  }
  TLV::DICTIONARIES["ASN"] = dict
end
make_dict

#TLV::DICTIONARIES["ASN"].each_pair{|key,value|
#  puts "#{TLV.b2s(key)} #{value}"
#}

