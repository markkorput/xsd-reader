module XsdReader
  class Choice
    include Shared

    # For a choice element we want to return each possible choice as its own choice group,
    # giving the party responsible for filling the xml the option to choose which choice group should be used.
    def elements_and_choices(opts = {})
      nodes.map{|node| node_to_object(node)}.compact.map do |obj|
        obj.is_a?(Element) ? [obj] : obj.elements_and_choices
      end
    end
  end # class Choice
end # module XsdReader