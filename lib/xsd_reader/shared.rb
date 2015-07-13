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

    def [](*args)
      # now name is always an array
      names = args.flatten

      result = self

      names.each do |curname|
        next if result.nil?
        if curname.to_s =~ /^\@/ 
          attr_name = curname.to_s.gsub(/^\@/, '')
          result = result.attributes.find{|attr| attr.name == attr_name}
        else
          result = result.elements.find{|child| child.name == curname.to_s}
        end
      end

      return result
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

    # base stuff belongs to extension type objects only, but let's be flexible
    def base
      node.attributes['base'] ? node.attributes['base'].value : nil
    end

    def base_name
      base ? base.type.split(':').last : nil
    end

    def base_namespace
      base ? base.type.split(':').first : nil
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
        'xs:extension' => Extension,
        'xs:import' => Import,
        'xs:simpleType' => SimpleType
      }

      return class_mapping[n.is_a?(Nokogiri::XML::Node) ? n.name : n]
    end

    def node_to_object(node)
      fullname = [node.namespace ? node.namespace.prefix : nil, node.name].reject{|str| str.nil? || str == ''}.join(':')
      klass = class_for(fullname)
      # logger.debug "node_to_object, klass: #{klass.to_s}, fullname: #{fullname}"
      klass.nil? ? nil : klass.new(options.merge(:node => node, :schema => schema))
    end

    #
    # Child objects
    #

    def mappable_children(xml_name)
      node.search("./#{xml_name}").to_a
    end

    def map_children(xml_name)
      # puts "Map Children with #{xml_name} for #{self.class.to_s}"
      mappable_children(xml_name).map{|current_node| node_to_object(current_node)}
    end

    def direct_elements
      @direct_elements ||= map_children("xs:element")
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
      @all_elements ||= ordered_elements + (linked_complex_type ? linked_complex_type.ordered_elements : [])
    end

    def child_elements?
      elements.length > 0
    end

    def attributes
      @attributes ||= map_children('xs:attribute')
    end

    def sequences
      @sequences ||= map_children("xs:sequence",)
    end

    def choices
      @choices ||= map_children("xs:choice")
    end

    def complex_types
      @complex_types ||= map_children("xs:complexType")
    end

    def complex_type
      complex_types.first
    end

    def linked_complex_type
      @linked_complex_type ||= object_by_name('xs:complexType', type) || object_by_name('xs:complexType', type_name) 
    end

    def simple_contents
      @simple_contents ||= map_children("xs:simpleContent")
    end

    def simple_content
      simple_contents.first
    end

    def extensions
      @extensions ||= map_children("xs:extension")
    end

    def extension
      extensions.first
    end

    def simple_types
      @simple_types ||= map_children("xs:simpleType")
    end

    def linked_simple_type
      @linked_simple_type ||= object_by_name('xs:simpleType', type) || object_by_name('xs:simpleType', type_name)
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

    def schema
      return options[:schema] if options[:schema]
      schema_node = node.search('//xs:schema')[0]
      return schema_node.nil? ? nil : node_to_object(schema_node)
    end

    def object_by_name(xml_name, name)
      # find in local schema, then look in imported schemas
      nod = node.search("//#{xml_name}[@name=\"#{name}\"]").first
      return node_to_object(nod) if nod

      # try to find in any of the importers
      self.schema.imports.each do |import|
        if obj = import.reader.schema.object_by_name(xml_name, name)
          return obj
        end
      end

      return nil
    end

    def elements_by_type(type_name)
      els = schema.node.search("//xs:element[@type=\"#{type_name}\"]")

      schema.node.search("//xs:element[@type=\"#{type_name}\"]")

      while els.length == 0

      end
    end

  end

end # module XsdReader