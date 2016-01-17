require 'xsd_reader/shared'

module XsdReader
  class Element
    include Shared

    def elements(opts = {})
      return super if opts[:direct] == true
      all_elements
    end

    def attributes
      @_element_attributes ||= super + (complex_type ? complex_type.attributes : [])
    end

    def complex_type
      @_element_complex_type ||= super || linked_complex_type
    end

    def min_occurs
      node.attributes['minOccurs'] ? node.attributes['minOccurs'].value.to_i : nil
    end

    def max_occurs
      val = node.attributes['maxOccurs'] ? node.attributes['maxOccurs'].value : nil
      val == 'unbounded' ? :unbounded : val.nil? ? nil : val.to_i
    end

    def multiple_allowed?
      max_occurs == :unbounded || max_occurs.to_i > 0
    end

    def required?
      min_occurs.nil? || min_occurs.to_i > 0 # TODO; consider if the element is part of a choice definition?
    end

    def optional?
      !required?
    end

    def family_tree(stack = [])
      logger.warn('Usage of the family tree function is not recommended as it can take very long to execute and is very memory intensive')
      return @_cached_family_tree if @_cached_family_tree

      if stack.include?(name) # avoid endless recursive loop
        # logger.debug "Element#family_tree aborting endless recursive loop at element with name: #{name} and element stack: #{stack.inspect}"
        return nil
      end

      return "type:#{type_name}" if elements.length == 0

      result = elements.inject({}) do |tree, element|
        tree.merge element.name => element.family_tree(stack + [name])
      end

      @_cached_family_tree = result if stack == [] # only cache if this was the first one called (otherwise there will be way too many caches)
      return result
    end
  end # class Element
end # module XsdReader
