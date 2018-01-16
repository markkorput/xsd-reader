module XsdReader
  class Choice
    include Shared

    def elements(opts = {})
      super.uniq{ |el| el.is_a?(Element) ? el.name : el }
    end

    def ordered_elements
      super.uniq{ |el| el.is_a?(Element) ? el.name : el }
    end
  end # class Choice
end # module XsdReader