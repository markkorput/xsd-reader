module XsdReader
  class SimpleContent
    include Shared

    def attributes
      super + (extension ? extension.attributes : [])
    end
  end # class Schema
end