require File.dirname(__FILE__) + '/spec_helper'

describe XsdReader::Import do
  let(:reader){
    XsdReader::XML.new(:xsd_file => File.expand_path(File.join(File.dirname(__FILE__), 'examples', 'ddex-ern-v36.xsd')))
  }

  let(:import){
    reader.imports[0]
  }

  it "gives the namespace" do
    expect(import.namespace).to eq 'http://ddex.net/xml/avs/avs'
  end

  it "gives the schema location" do
    expect(import.schema_location).to eq 'avs.xsd'
  end

  it "gives a download uri" do
    expect(import.uri).to eq 'http://ddex.net/xml/avs/avs.xsd'
  end

  it "downloads related xsd files" do
    r1 = XsdReader::XML.new(:xsd_file => File.expand_path(File.join(File.dirname(__FILE__), 'examples', 'avs.xsd')))
    r2 = XsdReader::XML.new(:xsd_xml => import.download)
    expect(r1.elements.map(&:name)).to eq r2.elements.map(&:name)
    expect(r1.simple_types.map(&:name)).to eq r2.simple_types.map(&:name)
  end
end # describe XsdReader::Import