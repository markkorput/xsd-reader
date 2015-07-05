require 'xsd_reader/shared'

module XsdReader
  class Element
    include Shared

    def elements(opts = {})
      return super if opts[:direct] == true
      all_elements
    end

    def attributes
      super + (complex_type ? complex_type.attributes : [])
    end

    def complex_type
      super || linked_complex_type
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