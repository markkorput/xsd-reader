require File.dirname(__FILE__) + '/spec_helper'

describe XsdReader::Element do

  let(:reader){
    XsdReader::XML.new(:xsd_file => File.expand_path(File.join(File.dirname(__FILE__), 'examples', 'ddex-v36', 'ddex-ern-v36.xsd')))
  }

  let(:element){
    reader.elements[0]
  }

  let(:referencing_reader){
    XsdReader::XML.new(:xsd_file => File.expand_path('examples/referencing.xsd', File.dirname(__FILE__)))
  }

  describe '#[]' do
    it "gives an element's child" do
      expect(reader['NewReleaseMessage']).to eq reader.elements[0]
    end

    it "gives an element's child through reference element" do
      expect(referencing_reader['Album', 'Tracks', 'Track', 'ISRC'].type).to eq 'xs:NCName'
    end
  end

  describe '#name' do
    it "gives the element's name" do
      expect(element.name).to eq 'NewReleaseMessage'
    end

    it "gives the element's name obtained through reference" do
      expect(referencing_reader.elements[0].elements[0].name).to eq 'Source'
    end
  end

  describe '#ref' do
    it "gives an element's ref attribute value" do
      expect(referencing_reader['Album']['Source'].ref).to eq 'Source'
    end

    it "returns nil when attribute available" do
      expect(element.ref).to eq nil
    end
  end

  describe '#type' do
    it "gives the type of an element" do
      expect(reader['NewReleaseMessage']['MessageHeader'].type).to eq 'ern:MessageHeader'
    end

    it "gives the type of an elements obtained through the referenced element" do
      expect(referencing_reader['Album']['Source'].type).to eq 'xs:string'
    end
  end

  describe '#complex_type' do
    it "gives a complex type reader" do
      expect(element.complex_type.class).to eq XsdReader::ComplexType
    end
  end

  describe "#elements" do
    it "gives child elements in the right order" do
      expected = [
        "CommercialModelType",
        "Usage",
        "AllDealsCancelled",
        "TakeDown",
        "TerritoryCode",
        "ExcludedTerritoryCode",
        "DistributionChannel",
        "ExcludedDistributionChannel",
        "PriceInformation",
        "IsPromotional",
        "PromotionalCode",
        "ValidityPeriod",
        "ConsumerRentalPeriod",
        "PreOrderReleaseDate",
        "ReleaseDisplayStartDate",
        "TrackListingPreviewStartDate",
        "CoverArtPreviewStartDate",
        "ClipPreviewStartDate",
        "PreOrderPreviewDate",
        "IsExclusive",
        "RelatedReleaseOfferSet",
        "PhysicalReturns",
        "NumberOfProductsPerCarton",
        "RightsClaimPolicy",
        "WebPolicy"]

      # byebug

      expect(reader['NewReleaseMessage']['DealList']['ReleaseDeal']['Deal']['DealTerms'].elements.map(&:name)).to eq expected
    end

    it "includes elements within a choice node" do
      el = element.elements[3]
      expect(el.name).to eq 'CatalogTransfer'
      elements_without = ["CatalogTransferCompleted", "EffectiveTransferDate", "CatalogReleaseReferenceList", "TransferringFrom", "TransferringTo"]
      elements_with = ["CatalogTransferCompleted", "EffectiveTransferDate", "CatalogReleaseReferenceList", "TerritoryCode", "ExcludedTerritoryCode", "TransferringFrom", "TransferringTo"]
      expect(el.complex_type.sequences.map{|seq| seq.elements}.flatten.map(&:name)).to eq elements_without
      expect(el.complex_type.all_elements.map(&:name)).to eq elements_with
      expect(el.complex_type.sequences[0].choices.map{|ch| ch.elements}.flatten.map(&:name)).to eq elements_with - elements_without      
    end

    it "gives child elements defined within a complex type" do
      # byebug
      expect(element.elements.map(&:name)).to eq [
        "MessageHeader",
        "UpdateIndicator",
        "IsBackfill",
        "CatalogTransfer",
        "WorkList",
        "CueSheetList",
        "ResourceList",
        "CollectionList",
        "ReleaseList",
        "DealList"]
    end

    it "gives child elements defined in the referenced element" do
      expect( referencing_reader['Album', 'Tracks'].elements.map(&:name) ).to eq ['Track']
      expect(referencing_reader['Album', 'Tracks', 'Track'].elements.map(&:name)).to eq [
        'ISRC',
        'Artist',
        'Title',
        'DiscNumber',
        'TrackNumber',
        'Duration',
        'Label',
        'Company',
        'CompanyCountry',
        'RecordedCountry',
        'RecordedYear',
        'ReleaseDate',
        'Contributors']
    end
  end

  describe '#attributes' do
    it "gives attributes defined in a complexType" do
      expected = [
        "MessageSchemaVersionId",
        "BusinessProfileVersionId",
        "ReleaseProfileVersionId",
        "LanguageAndScriptCode"]
      expect(element.attributes.map(&:name)).to eq expected
      expect(element.complex_type.attributes.map(&:name)).to eq expected
    end

    it "gives attributes defined in a simpleContent extension" do
      expect(element['ResourceList']['SoundRecording']['SoundRecordingDetailsByTerritory']['DisplayArtist']['ArtistRole'].attributes.map(&:name)).to eq ["Namespace", "UserDefinedValue"]
    end

    it "gives attributes defined in the referenced element" do
      expect(referencing_reader['Album', 'Tracks', 'Track'].attributes).to eq []
      expect(referencing_reader['Album', 'Tracks', 'Track', 'Contributors', 'Contributor'].attributes.map(&:name)).to eq ['credited']
    end
  end

  describe "External type definition" do
    let(:header){
      element.elements.first
    }

    it "gives the type name" do
      expect(header.type_name).to eq 'MessageHeader'
    end

    it "gives the type namespace" do
      expect(header.type_namespace).to eq 'ern'
    end

    it "gives the type string" do
      expect(header.type).to eq 'ern:MessageHeader'
    end

    it "gives the remote complex_type, linked by type" do
      expect(header.complex_type.name).to eq 'MessageHeader'
    end

    it "includes child elements defined in external the complex type type definitions" do
      expected = [
        "MessageThreadId",
        "MessageId",
        "MessageFileName",
        "MessageSender",
        "SentOnBehalfOf",
        "MessageRecipient",
        "MessageCreatedDateTime",
        "MessageAuditTrail",
        "Comment",
        "MessageControlType"]

      expect(header.elements.map(&:name)).to eq expected
      expect(header.complex_type.all_elements.map(&:name)).to eq expected
    end
  end

  # # this is pretty slow...
  # describe "#family_tree" do
  #   before :each do
  #     element = reader.elements[0]
  #   end

  #   it "gives a family tree as a nested list of children, keys being nodes name, values being either another hash of children of strings with the names of the children" do
  #     expect(element.family_tree.keys).to eq [
  #       "MessageHeader",
  #       "UpdateIndicator",
  #       "IsBackfill",
  #       "CatalogTransfer",
  #       "WorkList",
  #       "CueSheetList",
  #       "ResourceList",
  #       "CollectionList",
  #       "ReleaseList",
  #       "DealList"
  #     ]

  #     expect(element.family_tree['ResourceList'].keys).to eq [
  #       "SoundRecording",
  #       "MIDI",
  #       "Video",
  #       "Image",
  #       "Text",
  #       "SheetMusic",
  #       "Software",
  #       "UserDefinedResource"
  #     ]

  #     expect(element.family_tree['DealList']['ReleaseDeal']['Deal']['DealTerms']['RightsClaimPolicy']['Condition']['Unit']).to eq 'type:UnitOfConditionValue'
  #   end
  # end
end
