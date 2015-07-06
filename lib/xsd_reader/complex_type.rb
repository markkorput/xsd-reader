module XsdReader

  class ComplexType
    include Shared

    def name
      node.attributes['name'] ? node.attributes['name'].value : nil
    end

    def attributes
      super + (simple_content ? simple_content.attributes : [])
    end

    def parent_element
      if parent.nil? || parent.is_a?(Schema) || !parent.is_a?(Element)
        parent_elements.first
      end
    end

    def parent_elements
      elements_by_type(self.name)
    end

  end # class ComplexType

end # module XsdReader