module XsdReader
  class Attribute
    include Shared

    def required?
      (node.attributes['use'] && node.attributes['use'].value == 'required') ? true : false
    end
  end # class Attribute
end # module XsdReader