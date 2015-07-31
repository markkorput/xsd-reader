require File.dirname(__FILE__) + '/spec_helper'

describe XsdReader::Extension do
  let(:reader){
    XsdReader::XML.new(:xsd_file => File.expand_path(File.join(File.dirname(__FILE__), 'examples', 'ddex-v32', 'ern-main.xsd')))
  }

  let(:element){
    reader['NewReleaseMessage']['ResourceList']['SoundRecording']['SoundRecordingDetailsByTerritory']
  }

  let(:extension){
    element.complex_type.complex_content.extension
  }

  describe "#linked_complex_type" do
    it "finds linked complex typesfom imported schemas" do
      expect(extension.base).to eq 'ddexC:SoundRecordingDetailsByTerritory'
      expect(extension.linked_complex_type.name).to eq 'SoundRecordingDetailsByTerritory'
      expect(extension.linked_complex_type.schema).to be extension.schema.imports[1].reader.schema
    end
  end

  describe "#ordered_elements" do
    it "includes elements at the start from imported linked comlex type" do
      expect(extension.ordered_elements.map(&:name)).to eq ["TerritoryCode", "ExcludedTerritoryCode", "Title", "DisplayArtist", "ResourceContributor", "IndirectResourceContributor", "RightsAgreementId", "LabelName", "RightsController", "RemasteredDate", "OriginalResourceReleaseDate", "PLine", "CourtesyLine", "SequenceNumber", "HostSoundCarrier", "MarketingComment", "Genre", "ParentalWarningType", "AvRating", "TechnicalSoundRecordingDetails", "FulfillmentDate", "Keywords", "Synopsis"]
    end
  end

  describe "nested extensions" do
    it 'should allow extensions to extend other extensions transparently' do
      el = reader['NewReleaseMessage']['ResourceList']['Video']['VideoDetailsByTerritory']
      expect(el.elements.map(&:name)).to eq ["TerritoryCode", "ExcludedTerritoryCode", "Title", "DisplayArtist", "ResourceContributor", "IndirectResourceContributor", "RightsAgreementId", "LabelName", "RightsController", "RemasteredDate", "OriginalResourceReleaseDate", "PLine", "CourtesyLine", "SequenceNumber", "HostSoundCarrier", "MarketingComment", "Genre", "ParentalWarningType", "AvRating", "FulfillmentDate", "Keywords", "Synopsis", "CLine", "TechnicalVideoDetails", "Character"]
    end
  end
end # describe XsdReader::Extension