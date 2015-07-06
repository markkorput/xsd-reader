require 'logger'

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

    def nodes
      node.search("./*")
    end

    def [](name)
      # starts with an @-symbol? Then we're looking for an attribute
      if name =~ /^\@/ 
        attr_name = name.gsub(/^\@/, '')
        return attributes.find{|attr| attr.name == attr_name}
      end
      elements.find{|el| el.name == name}
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
    # Node to class mapping
    #
    def class_for(n)
      class_mapping = {
        'xs:schema' => Schema,
        'xs:element' => Element,
        'xs:attribute' => Attribute,
        'xs:choice' => Choice,
        'xs:complexType' => ComplexType,
        'xs:sequence' => Sequence,
        'xs:simpleContent' => SimpleContent,
        'xs:extension' => Extension
      }

      return class_mapping[n.is_a?(Nokogiri::XML::Node) ? n.name : n]
    end

    def node_to_object(node)
      fullname = [node.namespace ? node.namespace.prefix : nil, node.name].reject{|str| str.nil? || str == ''}.join(':')
      klass = class_for(fullname)
      # logger.debug "node_to_object, klass: #{klass.to_s}, fullname: #{fullname}"
      klass.nil? ? nil : klass.new(options.merge(:node => node))
    end


    #
    # Child objects
    #

    def map_children(xml_name, klass = nil)
      klass ||= class_for(xml_name)
      node.search("./#{xml_name}").map{|node| klass.new(options.merge(:node => node))}
    end

    def direct_elements
      map_children("xs:element")
    end

    def elements
      direct_elements
    end

    def unordered_elements
      direct_elements + (complex_type ? complex_type.all_elements : []) + sequences.map(&:all_elements).flatten + choices.map(&:all_elements).flatten
    end

    def ordered_elements
      # loop over each interpretable child xml node, and if we can convert a child node
      # to an XsdReader object, let it give its compilation of all_elements
      nodes.map{|node| node_to_object(node)}.compact.map do |obj|
        obj.is_a?(Element) ? obj : obj.all_elements
      end.flatten
    end

    def all_elements
      ordered_elements + (linked_complex_type ? linked_complex_type.ordered_elements : [])
    end

    def child_elements?
      elements.length > 0
    end

    def attributes
      map_children('xs:attribute')
    end

    def sequences
      map_children("xs:sequence",)
    end

    def choices
      map_children("xs:choice")
    end

    def complex_types
      map_children("xs:complexType")
    end

    def complex_type
      complex_types.first
    end

    def linked_complex_type
      complex_type_by_name(type) || complex_type_by_name(type_name)
    end

    def simple_contents
      map_children("xs:simpleContent")
    end

    def simple_content
      simple_contents.first
    end

    def extensions
      map_children("xs:extension")
    end

    def extension
      extensions.first
    end

    #
    # Related objects
    #

    def parent
      if node && node.respond_to?(:parent) && node.parent
        return node_to_object(node.parent)
      end

      nil
    end

    # def ancestors
    #   result = [parent]

    #   while result.first != nil
    #     result.unshift (result.first.respond_to?(:parent) ? result.first.parent : nil)
    #   end

    #   result.compact
    # end

    def schema
      p = node.parent

      while p.name != 'schema' && !p.nil?
        p = p.parent
      end
      p.nil? ? nil : node_to_object(p)
    end

    def complex_type_by_name(name)
      ct = node.search("//xs:complexType[@name=\"#{name}\"]").first
      ct.nil? ? nil : ComplexType.new(options.merge(:node => ct))
    end

    def elements_by_type(type_name)
      els = schema.node.search("//xs:element[@type=\"#{type_name}\"]")

      schema.node.search("//xs:element[@type=\"#{type_name}\"]")

      while els.length == 0

      end
    end

  end

end # module XsdReader