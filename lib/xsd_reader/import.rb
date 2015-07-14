require 'rest-client'

module XsdReader
  class Import
    include Shared

    def namespace
      node.attributes['namespace'] ? node.attributes['namespace'].value : nil
    end

    def schema_location
      node.attributes['schemaLocation'] ? node.attributes['schemaLocation'].value : nil
    end

    def reader
      return @reader || options[:reader] if @reader || options[:reader]
      if download_path
        File.write(download_path, download) if !File.file?(download_path)
        return @reader = XsdReader::XML.new(:xsd_file => download_path)
      end

      return @reader = XsdReader::XML.new(:xsd_xml => download) 
    end

    def uri
      if namespace =~ /\.xsd$/
        namespace
      else
        namespace.gsub(/#{File.basename(schema_location, '.*')}$/, '').to_s + schema_location
      end
    end

    def download
      @download ||= download_uri(self.uri)
    end

    def download_path
      # we need the parent XSD's path
      return nil if options[:xsd_file].nil?
      parent_path = File.dirname(options[:xsd_file])
      File.join(parent_path, File.basename(schema_location))
    end

    def local_xml
      File.file?(download_path) ? File.read(download_path) : download
    end

    private

    def download_uri(uri)
      logger.info "Downloading import schema from (uri)"
      response = RestClient.get uri
      return response.body
    end
  end # class Import
end