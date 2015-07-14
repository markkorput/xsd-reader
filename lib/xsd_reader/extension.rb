module XsdReader
  class Extension
    include Shared

    def linked_complex_type
      @linked_complex_type ||= (schema_for_namespace(base_namespace) || schema).complex_types.find{|ct| ct.name == (base_name)}
    end

    def ordered_elements
      (linked_complex_type ? linked_complex_type.ordered_elements : []) + super
    end
  end # class Schema
end