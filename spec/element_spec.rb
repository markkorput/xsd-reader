require File.dirname(__FILE__) + '/spec_helper'

describe XsdReader::Element do

  before :all do
    @reader ||= XsdReader::XML.new(:xsd_file => File.expand_path(File.join(File.dirname(__FILE__), 'examples', 'ddex-ern-v36.xsd')))
    @element = @reader.elements[0]
  end

  it "gives the element's name" do
    expect(@element.name).to eq 'NewReleaseMessage'
  end

  it "gives a complex type reader" do
    expect(@element.complex_type.class).to eq XsdReader::ComplexType
  end

  it "gives child elements defined within a complex type" do
    # byebug
    expect(@element.elements.map(&:name)).to eq [
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

  describe "External type definition" do
    before :each do
      @element = @element.elements.first
    end

    it "gives the type name" do
      expect(@element.type_name).to eq 'MessageHeader'
    end

    it "gives the type namespace" do
      expect(@element.type_namespace).to eq 'ern'
    end

    it "gives the type string" do
      expect(@element.type).to eq 'ern:MessageHeader'
    end

    it "gives the remote complex_type, linked by type" do
      expect(@element.complex_type.name).to eq 'MessageHeader'
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

      expect(@element.elements.map(&:name)).to eq expected
      expect(@element.complex_type.all_elements.map(&:name)).to eq expected
    end
  end

  describe "#elements" do

    it "includes elements within a choice node" do
      el = @element.elements[3]
      expect(el.name).to eq 'CatalogTransfer'
      elements_without = ["CatalogTransferCompleted", "EffectiveTransferDate", "CatalogReleaseReferenceList", "TransferringFrom", "TransferringTo"]
      elements_with = ["CatalogTransferCompleted", "EffectiveTransferDate", "CatalogReleaseReferenceList", "TerritoryCode", "ExcludedTerritoryCode", "TransferringFrom", "TransferringTo"]
      expect(el.complex_type.sequences.map{|seq| seq.elements}.flatten.map(&:name)).to eq elements_without
      expect(el.complex_type.all_elements.map(&:name)).to eq elements_with
      expect(el.complex_type.sequences[0].choices.map{|ch| ch.elements}.flatten.map(&:name)).to eq elements_with - elements_without      
    end

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

      expect(@reader['NewReleaseMessage']['DealList']['ReleaseDeal']['Deal']['DealTerms'].elements.map(&:name)).to eq expected
    end
  end

  # # this is pretty slow...
  # describe "#family_tree" do
  #   before :each do
  #     @element = @reader.elements[0]
  #   end

  #   it "gives a family tree as a nested list of children, keys being nodes name, values being either another hash of children of strings with the names of the children" do
  #     expect(@element.family_tree.keys).to eq [
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

  #     expect(@element.family_tree['ResourceList'].keys).to eq [
  #       "SoundRecording",
  #       "MIDI",
  #       "Video",
  #       "Image",
  #       "Text",
  #       "SheetMusic",
  #       "Software",
  #       "UserDefinedResource"
  #     ]

  #     expect(@element.family_tree['DealList']['ReleaseDeal']['Deal']['DealTerms']['RightsClaimPolicy']['Condition']['Unit']).to eq 'type:UnitOfConditionValue'
  #   end
  # end

  describe '#attributes' do
    it "gives attributes defined in a complexType" do
      expected = [
        "MessageSchemaVersionId",
        "BusinessProfileVersionId",
        "ReleaseProfileVersionId",
        "LanguageAndScriptCode"]
      expect(@element.attributes.map(&:name)).to eq expected
      expect(@element.complex_type.attributes.map(&:name)).to eq expected
    end

    it "gives attributes defined in a simpleContent extension" do
      expect(@element['ResourceList']['SoundRecording']['SoundRecordingDetailsByTerritory']['DisplayArtist']['ArtistRole'].attributes.map(&:name)).to eq ["Namespace", "UserDefinedValue"]
    end
  end

end
