require 'nokogiri'
# require 'open-uri'
require 'xsd_reader/shared' # for default_logger

module XsdReader

  class XML
    attr_reader :options

    def initialize(opts = {})
      @options = opts || {}
      raise "#{self.class}.new expects a hash parameter" if !@options.is_a?(Hash)
    end

    def logger
      options[:logger] || XsdReader::Shared.default_logger
    end

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

    def node
      nil
    end

    def schema_node
      doc.root.name == 'schema' ? doc.root : nil
    end

    def schema
      @schema ||= Schema.new(self.options.merge(:node => schema_node, :logger => logger))
    end

    # forwards most functions to schema
    def [](*args)
      schema[*args]
    end

    def elements
      schema.elements
    end

    def imports
      schema.imports
    end

    def simple_types
      schema.simple_types
    end

    def schema_for_namespace(_ns)
      schema.schema_for_namespace(_ns)
    end
  end # class XML

end # module XsdReader
