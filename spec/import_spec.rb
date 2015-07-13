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
    expected = File.read(File.expand_path(File.join(File.dirname(__FILE__), 'examples', 'avs.xsd')))
    expect(import.download).to eq expected
  end

end # describe XsdReader::Import