require File.dirname(__FILE__) + '/spec_helper'

describe XsdReader::Schema do
  let(:reader){
    XsdReader::XML.new(:xsd_file => File.expand_path(File.join(File.dirname(__FILE__), 'examples', 'ddex-v36', 'ddex-ern-v36.xsd')))
  }

  let(:schema){
    reader.schema
  }

  describe "#elements" do
    it "gives a element readers" do
      expect(schema.elements.map(&:class)).to eq [XsdReader::Element]*2
    end
  end

  describe '#target_namespace' do
    it "gives the target namespace" do
      expect(schema.target_namespace).to eq 'http://ddex.net/xml/ern/36'
    end
  end

  describe '#namespaces' do
    it 'returns a hash of namespace shortcuts' do
      expect(schema.namespaces).to eq({
        'xmlns:xs' => "http://www.w3.org/2001/XMLSchema",
        'xmlns:ern' => "http://ddex.net/xml/ern/36",
        'xmlns:avs' => "http://ddex.net/xml/avs/avs"
      })
    end
  end

  describe "#import_by_namespace" do
    it "returns import objects for the given namespace" do
      import = schema.import_by_namespace('http://ddex.net/xml/avs/avs')
      expect(import.class).to eq XsdReader::Import
      expect(import.namespace).to eq 'http://ddex.net/xml/avs/avs'
      expect(import.reader.schema.target_namespace).to eq 'http://ddex.net/xml/avs/avs'
      expect(import).to be schema.imports[0]
    end

    it "returns import objects for given namespace codes" do
      import = schema.import_by_namespace('avs')
      expect(import.class).to eq XsdReader::Import
      expect(import.namespace).to eq 'http://ddex.net/xml/avs/avs'
      expect(import.reader.schema.target_namespace).to eq 'http://ddex.net/xml/avs/avs'
      expect(import).to be schema.imports[0]
    end

    it "returns import objects for given namespace codes with xmlns prefix" do
      import = schema.import_by_namespace('xmlns:avs')
      expect(import.class).to eq XsdReader::Import
      expect(import.namespace).to eq 'http://ddex.net/xml/avs/avs'
      expect(import.reader.schema.target_namespace).to eq 'http://ddex.net/xml/avs/avs'
      expect(import).to be schema.imports[0]
    end

    it "returns nil when no matching import is found" do
      expect(schema.import_by_namespace('foo')).to eq nil
    end

    it "returns nil when a nil namespace is given" do
      expect(schema.import_by_namespace(nil)).to eq nil
    end
  end

  it "includes imported definitions as if they were local" do
    expect(schema.simple_types.map(&:name)).to eq ["ddex_LocalCollectionAnchorReference", "ddex_LocalResourceAnchorReference", "AccessLimitation", "AdministratingRecordCompanyRole", "AllTerritoryCode", "ArtistRole", "AudioCodecType", "BinaryDataType", "BusinessContributorRole", "CalculationType", "CarrierType", "CdProtectionType", "CharacterType", "CodingType", "CollectionType", "CommercialModelType", "CompilationType", "ContainerFormat", "CreationType", "CreativeContributorRole", "CueOrigin", "CueSheetType", "CueUseType", "CurrencyCode", "CurrentTerritoryCode", "DataMismatchResponseType", "DataMismatchStatus", "DataMismatchType", "DdexTerritoryCode", "DeductionRateType", "DeliveryActionType", "DeliveryMessageType", "DeprecatedCurrencyCode", "DeprecatedIsoTerritoryCode", "DigitizationMode", "DisputeReason", "DistributionChannelType", "DpidStatus", "DrmEnforcementType", "DrmPlatformType", "DsrMessageType", "EquipmentType", "ErnMessageType", "ErncFileStatus", "ErncProposedActionType", "ExpressionType", "ExternallyLinkedResourceType", "FileStatus", "FingerprintAlgorithmType", "GoverningAgreementType", "HashSumAlgorithmType", "ImageCodecType", "ImageType", "InvoiceAvailabilityStatus", "IsoCurrencyCode", "IsoLanguageCode", "IsoTerritoryCode", "LabelNameType", "LicenseOrClaimRefusalReason", "LicenseOrClaimRequestUpdateReason", "LicenseOrClaimUpdateReason", "LicenseRejectionReason", "LicenseStatus", "LicensingProcessStatus", "LodFileStatus", "LodProposedActionType", "MembershipType", "MessageActionType", "MessageContentRevenueType", "MessageContextType", "MessageControlType", "MidiType", "MlcMessageType", "MusicalWorkContributorRole", "MusicalWorkRightsClaimType", "MusicalWorkType", "MwlCaCMessageInBatchType", "MwnMessageType", "NewReleaseMessageStatus", "OperatingSystemType", "OrderType", "PLineType", "ParentalWarningType", "PartyRelationshipType", "PercentageType", "PriceInformationType", "PriceRangeType", "PriceType", "Priority", "ProductType", "ProjectContributorRelationshipType", "Purpose", "RateModificationType", "RatingAgency", "ReasonType", "RecipientRevenueType", "RecordingMode", "RedeliveryReasonType", "ReferenceUnit", "RelationalRelator", "ReleaseAvailabilityStatus", "ReleaseRelationshipType", "ReleaseResourceType", "ReleaseType", "ReportFormat", "ReportType", "RequestReason", "RequestedActionType", "ResourceContributorRole", "ResourceOmissionReason", "ResourceType", "RevenueSourceType", "RightShareRelationshipType", "RightShareType", "RightsClaimPolicyType", "RightsControllerRole", "RightsControllerType", "RightsCoverage", "RoyaltyRateCalculationType", "RoyaltyRateType", "SalesReportAvailabilityStatus", "Sex", "SheetMusicCodecType", "SheetMusicType", "SoftwareType", "SoundProcessorType", "SoundRecordingType", "SupplyChainStatus", "TaxScope", "TaxType", "TerritoryCodeType", "TerritoryCodeTypeIncludingDeprecatedCodes", "TextCodecType", "TextType", "ThemeType", "TisTerritoryCode", "TitleType", "TrackContributorRelationshipType", "UnitOfBitRate", "UnitOfConditionValue", "UnitOfExtent", "UnitOfFrameRate", "UnitOfFrequency", "UpdateIndicator", "UseType", "UserInterfaceType", "ValueType", "VideoCodecType", "VideoContentType", "VideoDefinitionType", "VideoType", "VisualPerceptionType", "VocalType", "WsMessageStatus", "TerritoryCode"]
  end
end # describe XsdReader::Schema
