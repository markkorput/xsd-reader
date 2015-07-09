require File.dirname(__FILE__) + '/spec_helper'

describe XsdReader do
  let(:reader){
    XsdReader::XML.new(:xsd_file => File.expand_path(File.join(File.dirname(__FILE__), 'examples', 'ddex-ern-v36.xsd')))
  }

  describe XsdReader::Schema do
    it "gives a element readers" do
      expect(reader.schema.elements.map(&:class)).to eq [XsdReader::Element]*2
    end
  end
end # describe XsdReader