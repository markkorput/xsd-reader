require File.dirname(__FILE__) + '/spec_helper'

describe XsdReader do
  let(:reader){
    XsdReader::XML.new(:xsd_file => File.expand_path(File.join(File.dirname(__FILE__), 'examples', 'ddex-v36', 'ddex-ern-v36.xsd')), :logger => spec_logger)
  }

  let(:v32){
    XsdReader::XML.new(:xsd_file => File.expand_path(File.join(File.dirname(__FILE__), 'examples', 'ddex-v32', 'ern-main.xsd')))
  }

  let(:ref_reader){
    XsdReader::XML.new(:xsd_file => File.expand_path('examples/referencing.xsd', File.dirname(__FILE__)))
  }

  # do caching tests first, so they can show the initial -cacheless- situation
  describe 'caching' do
    it 'start with caches empty' do
      cache_names = [:direct_elements, :attributes, :all_elements, :sequences, :choices, :complex_types, :linked_complex_type, :simple_contents, :extensions]
      expect(cache_names.map{|name| "#{name}: #{reader.instance_variable_get("@#{name}").inspect}"}).to eq cache_names.map{|name| "#{name}: #{nil.inspect}"}
    end

    it 'caches some relationships to improve performance' do
      expect(reader.instance_variable_get('@schema')).to eq nil
      expect(reader.instance_variable_get('@elements')).to eq nil
      # the next line causes new caches to be created
      expect(reader['NewReleaseMessage'].instance_variable_get('@all_elements')).to eq nil
      expect(reader.instance_variable_get('@schema').class).to eq XsdReader::Schema
      expect(reader.schema.instance_variable_get('@direct_elements').length).to eq 2
      # the next line causes new caches to be created
      expect(reader['NewReleaseMessage']['NewReleaseMessage'].instance_variable_get('@all_elements')).to eq nil
      expect(reader['NewReleaseMessage'].instance_variable_get('@all_elements').first.name).to eq 'MessageHeader'
      # etc.
    end
  end

  describe "#elements" do
    it "gives all child element definitions" do
      expect(reader.elements.map(&:name)).to eq ['NewReleaseMessage', 'CatalogListMessage']
      expect(reader.elements[0].elements[0].name).to eq 'MessageHeader'
    end
  end

  describe "#all_elements" do
    it "includes elements from linked complex types from an imported schema" do
      el = v32['NewReleaseMessage']['CollectionList']['Collection']['Title']
      expect(el.all_elements.map(&:name)).to eq ['TitleText', 'SubTitle']
    end

    it "includes elements from extensions in linked complex types" do
      el = v32['NewReleaseMessage']['ResourceList']['SoundRecording']['SoundRecordingDetailsByTerritory']
      expect(el.elements.map(&:name)).to eq ["TerritoryCode", "ExcludedTerritoryCode", "Title", "DisplayArtist", "ResourceContributor", "IndirectResourceContributor", "RightsAgreementId", "LabelName", "RightsController", "RemasteredDate", "OriginalResourceReleaseDate", "PLine", "CourtesyLine", "SequenceNumber", "HostSoundCarrier", "MarketingComment", "Genre", "ParentalWarningType", "AvRating", "TechnicalSoundRecordingDetails", "FulfillmentDate", "Keywords", "Synopsis"]
    end
  end

  describe "[] operator" do
    it "gives a child element object (matching by name)" do
      expect(reader['NewReleaseMessage'].name).to eq 'NewReleaseMessage'
    end

    it "supports linking" do
      # this supports linking:
      expect(reader['NewReleaseMessage']['ReleaseList']['Release'].attributes.map(&:name)).to eq ["LanguageAndScriptCode", "IsMainRelease"]
    end

    it "gives a specific element in the hierarchy when passing an array argument" do
      expect(reader[['NewReleaseMessage', 'ResourceList', 'SoundRecording']].name).to eq 'SoundRecording'
      expect(reader[['NewReleaseMessage', 'ResourceList', 'SoundRecording']].multiple_allowed?).to eq true
    end

    it "automatically turns symbol arguments into strings" do
      expect(reader[:NewReleaseMessage].name).to eq 'NewReleaseMessage'
      # this supports linking:
      expect(reader[:NewReleaseMessage]['ReleaseList'][:Release].attributes.map(&:name)).to eq ["LanguageAndScriptCode", "IsMainRelease"]
      expect(reader[:NewReleaseMessage, 'ReleaseList', :Release].attributes.map(&:name)).to eq ["LanguageAndScriptCode", "IsMainRelease"]
    end

    it "return nil and doesn't raise an exceptions when getting invalid input" do
      expect{
        expect(reader[:NewReleaseMessage, 'Nothing', '@Whatever', 'Foo']).to eq nil
      }.to_not raise_error
    end
  end

  describe "#child_elements?" do
    it "returns wether an element has child element definitions or not" do
      expect(reader['NewReleaseMessage'].child_elements?).to eq true
      expect(reader['NewReleaseMessage']['MessageHeader']['MessageThreadId'].child_elements?).to eq false
    end
  end

  describe "#min_occurs" do
    it "gives the minOccurs attribute as an integer" do
      expect(reader['NewReleaseMessage']['ResourceList']['SoundRecording'].min_occurs).to eq 0
    end

    it "returns nil when an element has no minOccurs attribute specified" do
      expect(reader['NewReleaseMessage']['ResourceList'].min_occurs).to eq nil
    end
  end

  describe "#max_occurs" do
    it "returns the :unbounded symbol when there's no limit to the number of occurences of the element" do
      expect(reader['NewReleaseMessage']['ResourceList']['SoundRecording'].max_occurs).to eq :unbounded
    end

    it "returns an integer value when there IS a limit to the number of occurences of the element" do
      expect(ref_reader['Album']['Foo']['Bar'].max_occurs).to eq 3
    end

    it "returns nil when nothing is specfied for the element" do
      expect(ref_reader['Album']['Tracks']['Track'].max_occurs).to eq nil
    end
  end

  describe "#multiple_allowed?" do
    it "indicates if multiple instances of an element are allowed" do
      expect(reader['NewReleaseMessage']['ResourceList'].multiple_allowed?).to be false
      expect(reader['NewReleaseMessage']['ResourceList']['SoundRecording'].multiple_allowed?).to be true
    end
  end

  describe "#required?" do
    it "indicates if an element is required" do
      expect(reader['NewReleaseMessage'].required?).to be true
      expect(reader['NewReleaseMessage']['ResourceList'].required?).to be true
      expect(reader['NewReleaseMessage']['CollectionList'].required?).to be false
    end

    it "indicates if an attribute is required" do
      expect(reader['NewReleaseMessage']['@MessageSchemaVersionId'].required?).to eq true
      expect(reader['NewReleaseMessage']['@LanguageAndScriptCode'].required?).to eq false
    end
  end

  describe "#optional?" do
    it "indicates if an element is optonal (opposite of required)" do
      expect(reader['NewReleaseMessage'].optional?).to be false
      expect(reader['NewReleaseMessage']['ResourceList'].optional?).to be false
      expect(reader['NewReleaseMessage']['CollectionList'].optional?).to be true
    end
  end

  describe "imports"  do
    it "finds imported types for elements" do
      simple_type = reader['NewReleaseMessage']['DealList']['ReleaseDeal']['Deal']['DealTerms']['WebPolicy']['AccessLimitation'].linked_simple_type
      expect(simple_type.class).to eq XsdReader::SimpleType
      expect(simple_type.name).to eq 'AccessLimitation'
      # byebug
      expect(simple_type.schema).to be reader.imports[0].reader.schema
    end
  end

  describe "#schema_for_namespace" do
    let(:v32){
      XsdReader::XML.new(:xsd_file => File.expand_path(File.join(File.dirname(__FILE__), 'examples', 'ddex-v32', 'ern-main.xsd')))
    }

    it "returns the schema object for a specified namespace" do
      expect(v32.schema_for_namespace('http://ddex.net/xml/2010/ern-main/32').target_namespace).to eq 'http://ddex.net/xml/2010/ern-main/32'
      expect(v32.schema_for_namespace('http://ddex.net/xml/2010/ern-main/32')).to be v32.schema
      expect(v32.schema.schema_for_namespace('http://ddex.net/xml/2010/ern-main/32')).to be v32.schema
      expect(v32['NewReleaseMessage'].schema_for_namespace('http://ddex.net/xml/2010/ern-main/32')).to be v32.schema
    end

    it "returns the schema object for a specified namespace code" do
      expect(v32.schema_for_namespace('ernm').target_namespace).to eq 'http://ddex.net/xml/2010/ern-main/32'
      expect(v32.schema_for_namespace('ernm')).to be v32.schema
      expect(v32.schema.schema_for_namespace('ernm')).to be v32.schema
      expect(v32['NewReleaseMessage']['ResourceList'].schema_for_namespace('ernm')).to be v32.schema
    end

    it "finds imported schemas" do
      expect(v32.schema_for_namespace('http://ddex.net/xml/20100712/ddexC').target_namespace).to eq 'http://ddex.net/xml/20100712/ddexC'
      expect(v32.schema_for_namespace('http://ddex.net/xml/20100712/ddexC')).to be v32.imports[1].reader.schema
      expect(v32.schema.schema_for_namespace('ddex').target_namespace).to eq 'http://ddex.net/xml/20100712/ddex'
      expect(v32.schema.schema_for_namespace('ddex')).to be v32.imports[0].reader.schema
      expect(v32.schema_for_namespace('ddexC').target_namespace).to eq 'http://ddex.net/xml/20100712/ddexC'
      expect(v32.schema_for_namespace('ddexC')).to be v32.imports[1].reader.schema
    end
  end

  describe "#linked_complex_type" do
    it "finds complex types for elements within the same schema" do
      el = reader['NewReleaseMessage']['MessageHeader']
      ct = el.linked_complex_type
      expect(ct.class).to eq XsdReader::ComplexType
      expect(ct.name).to eq 'MessageHeader'
      expect(ct.schema).to be el.schema
    end

    it "finds complex types for elements on imported schemas based on namespace prefix" do
      el = v32['NewReleaseMessage']['CollectionList']['Collection']['Title']
      ct = el.linked_complex_type
      expect(ct.class).to eq XsdReader::ComplexType
      expect(ct.name).to eq 'Title'
      expect(ct.schema).to be el.schema.imports[1].reader.schema
      expect(el.complex_type).to be ct
    end
  end

  describe "referenced elements" do
    let(:reader){
      ref_reader
    }

    let(:element){
      reader['Album', 'Tracks', 'Track', 'Contributors', 'Contributor']
    }

    describe '#referenced_element' do
      it 'gives the referenced element' do
        expect(element.referenced_element.class).to eq XsdReader::Element
        expect(element.referenced_element.name).to eq 'Contributor'
        expect(element.referenced_element).to_not eq element
      end
    end

    describe '#elements' do
      it "gives alements of the referenced element" do
        expect(element.elements.map(&:name)).to eq ['Name', 'Role', 'Instrument']
      end
    end

    describe '#attributes' do
      it "gives the attributes of the referenced element" do
        expect(element.attributes.map(&:name)).to eq ['credited']
      end
    end

    describe '#[]' do
      it "lets the caller acces elements of the referenced element" do
        expect(element['Role'].type).to eq 'xs:NCName'
      end

      it "lets the caller access attributes of the referened element" do
        expect(element['@credited'].type).to eq 'xs:boolean'
      end
    end

    describe '#name' do
      it "gives the name of the referenced element" do
        expect(element.name).to eq 'Contributor'
      end
    end

    describe '#type' do
      it "gives the type of the referenced element" do
        expect(element.type).to eq nil
        expect(reader['Album', 'Source'].type).to eq 'xs:string'
      end
    end

    describe '#complex_type' do
      it "gives the complex type object of the referenced element" do
        expect(element.complex_type.sequences.first.elements.map(&:name)).to eq ['Name', 'Role', 'Instrument']
      end
    end

    describe '#simple_contents' do
      it "it includes the referenced element's simple content objects" do
        skip 'not yet implemented'
      end
    end

    describe '#complex_contents' do
      it "it includes the referenced element's complex content objects" do
        skip 'not yet implemented'
      end
    end

    describe '#extensions' do
      it "it includes the referenced element's extension objects" do
        skip 'not yet implemented'
      end
    end

  end
end
