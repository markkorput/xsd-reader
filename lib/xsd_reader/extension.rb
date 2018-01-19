module XsdReader
  class Extension
    include Shared

    def linked_complex_type
      @linked_complex_type ||= (schema_for_namespace(base_namespace) || schema).complex_types.find{|ct| ct.name == (base_name)}
    end

    def order_elements(types_to_include)
      (linked_complex_type ? linked_complex_type.order_elements(types_to_include) : []) + super
    end
  end # class Schema
end