module XsdReader
  class Import
    include Shared

    def namespace
      node.attributes['namespace'] ? node.attributes['namespace'].value : nil
    end

    def schema_location
      node.attributes['schemaLocation'] ? node.attributes['schemaLocation'].value : nil
    end

    def uri
      if namespace =~ /\.xsd$/
        namespace
      else
        namespace.gsub(/#{File.basename(schema_location, '.*')}$/, '').to_s + schema_location
      end
    end

    def download
      nil
    end
  end # class Import
end