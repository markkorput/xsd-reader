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

    def uri
      if namespace =~ /\.xsd$/
        namespace
      else
        namespace.gsub(/#{File.basename(schema_location, '.*')}$/, '').to_s + schema_location
      end
    end

    def download
      download_uri(self.uri)
    end

    private

    def download_uri(uri)
      logger.info "Downloading import schema from (uri)"
      response = RestClient.get uri
      return response.body
    end
  end # class Import
end