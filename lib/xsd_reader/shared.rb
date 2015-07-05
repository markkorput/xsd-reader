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

    def map_children(xml_name, klass)
      node.search("./#{xml_name}").map{|node| klass.new(options.merge(:node => node))}
    end

    def elements
      map_children("xs:element", Element)
    end

    def all_elements
      elements + (complex_type ? complex_type.all_elements : []) + sequences.map(&:all_elements).flatten + choices.map(&:all_elements)
    end

    def sequences
      map_children("xs:sequence", Sequence)
    end

    def choices
      map_children("xs:choice", Choice)
    end

    def complex_type
      map_children("xs:complexType", ComplexType).first
    end

    def complex_type_by_name(name)
      ct = node.search("//xs:complexType[@name=\"#{name}\"]").first
      ct.nil? ? nil : ComplexType.new(options.merge(:node => ct))
    end
  end

end # module XsdReader