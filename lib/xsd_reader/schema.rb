module XsdReader
  class Schema
    include Shared

    def schema
      return self
    end

    def imports
      @imports ||= map_children("xs:import")
    end

    def mappable_children(xml_name)
      result = super
      result += import_mappable_children(xml_name) if xml_name != 'xs:import'
      return result.to_a
    end

    def import_mappable_children(xml_name)
      self.imports.map{|import| import.reader.schema.mappable_children(xml_name)}.flatten
    end
  end # class Schema
end