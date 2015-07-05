module XsdReader

  class ComplexType
    include Shared

    def name
      node.attributes['name'] ? node.attributes['name'].value : nil
    end

    def attributes
      super + (simple_content ? simple_content.attributes : [])
    end

  end # class ComplexType

end # module XsdReader