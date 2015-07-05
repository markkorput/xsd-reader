require File.dirname(__FILE__) + '/spec_helper'
require 'xsd_reader'

describe XsdReader do

  before :all do
    @reader ||= XsdReader::XML.new(:xsd_file => File.expand_path(File.join(File.dirname(__FILE__), 'examples', 'ddex-ern-v36.xsd')))
  end

  # before(:each) do    
  # end

  describe XsdReader::XML do
    it "gives a schema_node" do
      expect(@reader.schema_node.name).to eq 'schema'
      expect(@reader.schema_node.namespaces).to eq({"xmlns:xs"=>"http://www.w3.org/2001/XMLSchema", "xmlns:ern"=>"http://ddex.net/xml/ern/36", "xmlns:avs"=>"http://ddex.net/xml/avs/avs"})
    end

    it "gives a schema reader" do
      expect(@reader.schema.class).to eq XsdReader::Schema
    end

    it "gives an elements shortcut to its schema's shortcuts" do
      expect(@reader.elements.map(&:name)).to eq @reader.schema.elements.map(&:name)
    end
  end

  describe XsdReader::Schema do
    before :each do
      @schema = @reader.schema
    end

    it "gives an element readers" do
      expect(@schema.elements.map(&:class)).to eq [XsdReader::Element]*2
    end
  end

  describe XsdReader::Element do
    before :each do
      @element = @reader.elements[0]
    end

    it "gives the element's name" do
      expect(@element.name).to eq 'NewReleaseMessage'
    end

    it "gives a complex type reader" do
      expect(@element.complex_type.class).to eq XsdReader::ComplexType
    end

    it "gives child elements defined within a complex type" do
      expect(@element.child_elements.map(&:name)).to eq [
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
        @element = @element.child_elements.first
      end

      it "gives the type name" do
        expect(@element.type_name).to eq 'MessageHeader'
      end

      it "gives the type namespace" do
        expect(@element.type_namespace).to eq 'ern'
      end

      it "gives the type string" do
        expect(@element.full_type).to eq 'ern:MessageHeader'
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

        expect(@element.child_elements.map(&:name)).to eq expected
        expect(@element.complex_type.all_elements.map(&:name)).to eq expected
      end
    end

    describe "#child_elements" do

      it "includes child elements within a choice node" do
        el = @element.child_elements[3]
        expect(el.name).to eq 'CatalogTransfer'
        elements_without = ["CatalogTransferCompleted", "EffectiveTransferDate", "CatalogReleaseReferenceList", "TransferringFrom", "TransferringTo"]
        elements_extra = ["TerritoryCode", "ExcludedTerritoryCode"]
        expect(el.complex_type.sequences.map{|seq| seq.elements}.flatten.map(&:name)).to eq elements_without
        expect(el.complex_type.sequences[0].choices.map{|ch| ch.elements}.flatten.map(&:name)).to eq elements_extra
        expect(el.complex_type.all_elements.map(&:name)).to eq elements_without + elements_extra
      end    
    end
  end

  # use of this function is not recommended; it can be pretty slow
  # describe "#family_tree" do
  #   before :each do
  #     @element = @reader.elements[0]
  #   end

  #   it "gives a family tree as a nested list of children, keys being nodes name, values being either another hash of children of strings with the names of the children" do
  #     @element.family_tree.keys.should == [
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

  #     @element.family_tree['ResourceList'].keys.should == [
  #       "SoundRecording",
  #       "MIDI",
  #       "Video",
  #       "Image",
  #       "Text",
  #       "SheetMusic",
  #       "Software",
  #       "UserDefinedResource"
  #     ]

  #     @element.family_tree['DealList']['ReleaseDeal']['Deal']['DealTerms']['RightsClaimPolicy']['Condition']['Unit'].should == 'type:UnitOfConditionValue'
  #   end
  # end
end
