=begin
SOAP4R - WSDL mapping registry.
Copyright (C) 2000, 2001, 2002, 2003  NAKAMURA, Hiroshi.

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PRATICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program; if not, write to the Free Software Foundation, Inc., 675 Mass
Ave, Cambridge, MA 02139, USA.
=end


require 'soap/baseData'
require 'soap/mapping/mapping'
require 'soap/mapping/typeMap'


module SOAP
module Mapping


class WSDLRegistry
  include TraverseSupport

  attr_reader :complextypes

  def initialize(complextypes, config = {})
    @complextypes = complextypes
    @config = config
    @excn_handler_obj2soap = nil
    # For mapping AnyType element.
    @rubytype_factory = RubytypeFactory.new(
      :allow_untyped_struct => true,
      :allow_original_mapping => true
    )
  end

  def obj2soap(klass, obj, type_qname)
    soap_obj = nil
    if obj.nil?
      soap_obj = SOAPNil.new
    elsif obj.is_a?(NSDBase)
      soap_obj = soap2soap(obj, type_qname)
    elsif (type = @complextypes[type_qname])
      case type.compoundtype
      when :TYPE_STRUCT
        soap_obj = struct2soap(obj, type_qname, type)
      when :TYPE_ARRAY
        soap_obj = array2soap(obj, type_qname, type)
      end
    elsif (type = TypeMap[type_qname])
      soap_obj = base2soap(obj, type)
    elsif type_qname == XSD::AnyTypeName
      soap_obj = @rubytype_factory.obj2soap(nil, obj, nil, nil)
    end
    return soap_obj if soap_obj

    if @excn_handler_obj2soap
      soap_obj = @excn_handler_obj2soap.call(obj) { |yield_obj|
        Mapping._obj2soap(yield_obj, self)
      }
    end
    return soap_obj if soap_obj

    raise MappingError.new("Cannot map #{ klass.name } to SOAP/OM.")
  end

  def soap2obj(klass, node)
    raise RuntimeError.new("#{ self } is for obj2soap only.")
  end

  def excn_handler_obj2soap=(handler)
    @excn_handler_obj2soap = handler
  end

private

  def soap2soap(obj, type_qname)
    if obj.is_a?(SOAPBasetype)
      obj
    elsif obj.is_a?(SOAPStruct) && (type = @complextypes[type_qname])
      soap_obj = obj
      mark_marshalled_obj(obj, soap_obj)
      elements2soap(obj, soap_obj, type.content.elements)
      soap_obj
    elsif obj.is_a?(SOAPArray) && (type = @complextypes[type_qname])
      soap_obj = obj
      contenttype = type.child_type
      mark_marshalled_obj(obj, soap_obj)
      obj.replace do |ele|
	Mapping._obj2soap(ele, self, contenttype)
      end
      soap_obj
    else
      nil
    end
  end

  def base2soap(obj, type)
    soap_obj = nil
    if type <= XSD::XSDString
      soap_obj = type.new(Charset.is_ces(obj, $KCODE) ?
        Charset.encoding_conv(obj, $KCODE, Charset.encoding) : obj)
      mark_marshalled_obj(obj, soap_obj)
    else
      soap_obj = type.new(obj)
    end
    soap_obj
  end

  def struct2soap(obj, type_qname, type)
    soap_obj = SOAPStruct.new(type_qname)
    mark_marshalled_obj(obj, soap_obj)
    elements2soap(obj, soap_obj, type.content.elements)
    soap_obj
  end

  def array2soap(obj, type_qname, type)
    contenttype = type.child_type
    soap_obj = SOAPArray.new(ValueArrayName, 1, contenttype)
    mark_marshalled_obj(obj, soap_obj)
    obj.each do |item|
      soap_obj.add(Mapping._obj2soap(item, self, contenttype))
    end
    soap_obj
  end

  def elements2soap(obj, soap_obj, elements)
    elements.each do |element|
      name = element.name.name
      child_obj = obj.instance_eval("@#{ name }")
      soap_obj.add(name, Mapping._obj2soap(child_obj, self, element.type))
    end
  end
end


end
end
