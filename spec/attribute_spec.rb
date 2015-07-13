require File.dirname(__FILE__) + '/spec_helper'

describe XsdReader do
  let(:reader){
    XsdReader::XML.new(:xsd_file => File.expand_path(File.join(File.dirname(__FILE__), 'examples', 'ddex-v36', 'ddex-ern-v36.xsd')))
  }

  describe XsdReader::Attribute do
    let(:attribute){
      reader['NewReleaseMessage']['@MessageSchemaVersionId']
    }

    it "gives a name" do
      expect(attribute.name).to eq 'MessageSchemaVersionId'
    end

    it "gives a type information" do
      expect(attribute.type).to eq 'xs:string'
      expect(attribute.type_name).to eq 'string'
      expect(attribute.type_namespace).to eq 'xs'
    end

    it "gives a boolean required indication" do
      expect(attribute.required?).to eq true
    end
  end

  describe "[] operator" do
    it "gives attribute objects through the square brackets ([]) operator" do
      attribute = reader['NewReleaseMessage']['MessageHeader']['@LanguageAndScriptCode']
      expect(attribute.type).to eq 'xs:string'
      expect(attribute.required?).to eq false
    end
  end
end # describe XsdReader