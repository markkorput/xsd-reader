module XsdReader

  module Shared
    attr_reader :options

    def initialize(_opts = {})
      @options = _opts || {}
      raise "#{self.class.to_s}.new expects a hash parameter" if !@options.is_a?(Hash)
    end

    def logger
      @logger ||= options[:logger] || Logger.new(STDOUT)
    end

    def node
      options[:node]
    end

    #
    # attribute properties
    #
    def name
      node.attributes['name'].value
    end

    def type
      node.attributes['type'] ? node.attributes['type'].value : nil
    end

    def type_name
      type ? type.split(':').last : nil
    end

    def type_namespace
      type ? type.split(':').first : nil
    end

    #
    # Child objects
    #
    def map_children(xml_name, klass)
      node.search("./#{xml_name}").map{|node| klass.new(options.merge(:node => node))}
    end

    def direct_elements
      map_children("xs:element", Element)
    end

    def elements
      direct_elements
    end

    def all_elements
      direct_elements + (complex_type ? complex_type.all_elements : []) + sequences.map(&:all_elements).flatten + choices.map(&:all_elements).flatten
    end

    def attributes
      map_children('xs:attribute', Attribute)
    end

    def sequences
      map_children("xs:sequence", Sequence)
    end

    def choices
      map_children("xs:choice", Choice)
    end

    def complex_types
      map_children("xs:complexType", ComplexType)
    end

    def complex_type
      complex_types.first
    end

    def simple_contents
      map_children("xs:simpleContent", SimpleContent)
    end

    def simple_content
      simple_contents.first
    end

    def extensions
      map_children("xs:extension", Extension)
    end

    def extension
      extensions.first
    end

    #
    # Related objects
    #
    def complex_type_by_name(name)
      ct = node.search("//xs:complexType[@name=\"#{name}\"]").first
      ct.nil? ? nil : ComplexType.new(options.merge(:node => ct))
    end
  end

end # module XsdReader