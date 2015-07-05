require 'xsd_reader/shared'

module XsdReader
  class Element
    include Shared

    def name
      node.attributes['name'].value
    end

    def child_elements
      elements + (complex_type ? complex_type.all_elements : [])
    end

    def full_type
      node.attributes['type'] ? node.attributes['type'].value : nil
    end

    def type_name
      full_type ? full_type.split(':').last : nil
    end

    def type_namespace
      full_type ? full_type.split(':').first : nil
    end

    def complex_type
      super || complex_type_by_name(full_type) || complex_type_by_name(type_name)
    end

    def family_tree(stack = [])
      return @_cached_family_tree if @_cached_family_tree 

      if stack.include?(name) # avoid endless recursive loop
        # logger.debug "Element#family_tree aborting endless recursive loop at element with name: #{name} and element stack: #{stack.inspect}"
        return nil
      end

      return "type:#{type_name}" if child_elements.length == 0

      result = child_elements.inject({}) do |tree, child_element|
        tree.merge child_element.name => child_element.family_tree(stack + [name])
      end

      @_cached_family_tree = result if stack == [] # only cache if this was the first one called (otherwise there will be way too many caches)
      return result
    end
  end # class Element
end # module XsdReader