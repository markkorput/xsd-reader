require File.dirname(__FILE__) + '/spec_helper'

describe XsdReader do

  let(:reader){
    XsdReader::XML.new(:xsd_file => File.expand_path(File.join(File.dirname(__FILE__), 'examples', 'ddex-ern-v36.xsd')))
  }

  describe XsdReader::XML do
    it "gives a schema_node" do
      expect(reader.schema_node.name).to eq 'schema'
      expect(reader.schema_node.namespaces).to eq({"xmlns:xs"=>"http://www.w3.org/2001/XMLSchema", "xmlns:ern"=>"http://ddex.net/xml/ern/36", "xmlns:avs"=>"http://ddex.net/xml/avs/avs"})
    end

    it "gives a schema reader" do
      expect(reader.schema.class).to eq XsdReader::Schema
    end

    it "gives an elements shortcut to its schema's shortcuts" do
      expect(reader.elements.map(&:name)).to eq reader.schema.elements.map(&:name)
    end
  end

end # describe XsdReader