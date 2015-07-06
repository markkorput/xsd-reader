require 'nokogiri'
# require 'open-uri'

module XsdReader

  class XML
    include Shared

    def xsd_from_uri
      # @xsd_from_uri ||= options[:xsd_uri].nil ? nil : open(options[:xsd_uri])
    end

    def xsd_from_file
      @xsd_from_file ||= options[:xsd_file].nil? ? nil : File.read(options[:xsd_file])
    end

    def xml
      @xsd_xml ||= options[:xsd_xml] || options[:xsd_data] || options[:xsd_raw] || xsd_from_file || xsd_from_uri
    end

    def doc
      @doc ||= Nokogiri.XML(xml)
    end

    def schema_node
      doc.root.name == 'schema' ? doc.root : nil
    end

    def schema
      node_to_object(schema_node)
    end

    def elements
      schema.elements
    end
  end # class XML

end # module XsdReader