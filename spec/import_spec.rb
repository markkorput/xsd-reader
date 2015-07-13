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

  it "gives a reader for the external XSD" do
    expect(import.reader.class).to eq XsdReader::XML
  end

  it "gives a download_path to save the imported xsd file to, if an xsd_file options is provided, containing the path to the parent xsd" do
    expect(import.options[:xsd_file]).to eq reader.options[:xsd_file]
    expect(import.download_path).to eq File.expand_path(File.join(File.dirname(__FILE__), 'examples', 'avs.xsd'))
  end

  it "downloads related xsd files" do
    r1 = XsdReader::XML.new(:xsd_file => File.expand_path(File.join(File.dirname(__FILE__), 'examples', 'avs.xsd')))
    r2 = import.reader
    expect(r1.elements.map(&:name)).to eq r2.elements.map(&:name)
    expect(r1.simple_types.map(&:name)).to eq r2.simple_types.map(&:name)
  end

  it "automatically saves related xsd content" do
    skip 'downloading test disabled for efficiency'
    FileUtils.rm(import.download_path) if File.exist?(import.download_path)
    # To get the reaed, the import object has to download the XSD data first,
    # which is automatically saved locally
    expect(import.reader.options[:xsd_file]).to eq File.expand_path(File.join(File.dirname(__FILE__), 'examples', 'avs.xsd'))
    expect(File.file?(import.download_path)).to eq true
  end
end # describe XsdReader::Import