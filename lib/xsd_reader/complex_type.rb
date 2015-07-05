module XsdReader

  class ComplexType
    include Shared

    def name
      node.attributes['name'] ? node.attributes['name'].value : nil
    end
  end # class ComplexType

end # module XsdReader