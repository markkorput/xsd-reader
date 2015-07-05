require File.dirname(__FILE__) + '/spec_helper'

describe XsdReader do
  before :all do
    @reader ||= XsdReader::XML.new(:xsd_file => File.expand_path(File.join(File.dirname(__FILE__), 'examples', 'ddex-ern-v36.xsd')))
  end

  describe XsdReader::Schema do
    before :each do
      @schema = @reader.schema
    end

    it "gives a element readers" do
      expect(@schema.elements.map(&:class)).to eq [XsdReader::Element]*2
    end
  end
end # describe XsdReader