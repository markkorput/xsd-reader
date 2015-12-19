require 'logger'

module XsdReader

  module Shared

    attr_reader :options

    def initialize(_opts = {})
      @options = _opts || {}
      raise "#{self.class.to_s}.new expects a hash parameter" if !@options.is_a?(Hash)
    end

    def logger
      return @logger if @logger
      @logger ||= options[:logger] || Logger.new(STDOUT)
      @logger.level = Logger::WARN
      return @logger
    end

    def node
      options[:node]
    end

    def schema_namespace_prefix
      @schema_namespace_prefix ||= [(self.node.namespaces||{}).detect {|ns| ns[1]=~/XMLSchema/}.first.split(':')[1],nil].uniq.join(':')
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
      name_local || name_referenced
    end

    def name_local
      node.attributes['name'] ? node.attributes['name'].value : nil
    end

    def name_referenced
      referenced_element ? referenced_element.name : nil
    end

    def ref
      node.attributes['ref'] ? node.attributes['ref'].value : nil
    end

    def referenced_element
      ref && schema ? schema.elements.find{|el| el.name == ref} : nil
    end


    def type
      type = node.attributes['type'] ? node.attributes['type'].value : nil
      type || (referenced_element ? referenced_element.type : nil)
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
      base ? base.split(':').last : nil
    end

    def base_namespace
      base ? base.split(':').first : nil
    end


    #
    # Node to class mapping
    #
    def class_for(n)
      class_mapping = {
        "#{schema_namespace_prefix}schema" => Schema,
        "#{schema_namespace_prefix}element" => Element,
        "#{schema_namespace_prefix}attribute" => Attribute,
        "#{schema_namespace_prefix}choice" => Choice,
        "#{schema_namespace_prefix}complexType" => ComplexType,
        "#{schema_namespace_prefix}sequence" => Sequence,
        "#{schema_namespace_prefix}simpleContent" => SimpleContent,
        "#{schema_namespace_prefix}complexContent" => ComplexContent,
        "#{schema_namespace_prefix}extension" => Extension,
        "#{schema_namespace_prefix}import" => Import,
        "#{schema_namespace_prefix}simpleType" => SimpleType
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

    def prepend_namespace name
      name =~ /^#{schema_namespace_prefix}/ ? name : "#{schema_namespace_prefix}#{name}"
    end

    def mappable_children(xml_name)
#3      p prepend_namespace(xml_name )
      node.search("./#{prepend_namespace xml_name}").to_a
    end

    def map_children(xml_name)
      # puts "Map Children with #{xml_name} for #{self.class.to_s}"
      mappable_children(xml_name).map{|current_node| node_to_object(current_node)}
    end

    def direct_elements
      @direct_elements ||= map_children("element")
    end

    def elements
      direct_elements
    end

    def ordered_elements
      # loop over each interpretable child xml node, and if we can convert a child node
      # to an XsdReader object, let it give its compilation of all_elements
      nodes.map{|node| node_to_object(node)}.compact.map do |obj|
        obj.is_a?(Element) ? obj : obj.ordered_elements
      end.flatten
    end

    def all_elements
      @all_elements ||= ordered_elements +
        (linked_complex_type ? linked_complex_type.all_elements : []) + 
        (referenced_element ? referenced_element.all_elements : [])
    end

    def child_elements?
      elements.length > 0
    end

    def attributes
      @attributes ||= map_children("attribute") #+
        #(referenced_element ? referenced_element.attributes : [])
    end

    def sequences
      @sequences ||= map_children("sequence")
    end

    def choices
      @choices ||= map_children("choice")
    end

    def complex_types
      @complex_types ||= map_children("complexType")
    end

    def complex_type
      complex_types.first || linked_complex_type || (referenced_element ? referenced_element.complex_type : nil)
    end

    def linked_complex_type
      @linked_complex_type ||= (schema_for_namespace(type_namespace) || schema).complex_types.find{|ct| ct.name == (type_name || type)}
      #@linked_complex_type ||= object_by_name('#{schema_namespace_prefix}complexType', type) || object_by_name('#{schema_namespace_prefix}complexType', type_name)
    end

    def simple_contents
      @simple_contents ||= map_children("simpleContent")
    end

    def simple_content
      simple_contents.first
    end

    def complex_contents
      @complex_contents ||= map_children("complexContent")
    end

    def complex_content
      complex_contents.first
    end

    def extensions
      @extensions ||= map_children("extension")
    end

    def extension
      extensions.first
    end

    def simple_types
      @simple_types ||= map_children("simpleType")
    end

    def linked_simple_type
      @linked_simple_type ||= object_by_name("#{schema_namespace_prefix}simpleType", type) || object_by_name("#{schema_namespace_prefix}simpleType", type_name)
      # @linked_simple_type ||= (type_namespace ? schema_for_namespace(type_namespace) : schema).simple_types.find{|st| st.name == (type_name || type)}
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

    def schema_for_namespace(_namespace)
      logger.debug "Shared#schema_for_namespace with _namespace: #{_namespace}"
      return schema if schema.targets_namespace?(_namespace)

      if import = schema.import_by_namespace(_namespace)
        logger.debug "Shared#schema_for_namespace found import schema"
        return import.reader.schema
      end

      logger.debug "Shared#schema_for_namespace no result"
      return nil
    end
  end

end # module XsdReader