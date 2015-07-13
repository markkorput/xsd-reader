require File.dirname(__FILE__) + '/spec_helper'

describe XsdReader::Schema do
  let(:reader){
    XsdReader::XML.new(:xsd_file => File.expand_path(File.join(File.dirname(__FILE__), 'examples', 'ddex-v36', 'ddex-ern-v36.xsd')))
  }

  let(:schema){
    reader.schema
  }

  it "gives a element readers" do
    expect(schema.elements.map(&:class)).to eq [XsdReader::Element]*2
  end

  it "includes imported definitions as if they were local" do
    expect(schema.simple_types.map(&:name)).to eq ["ddex_LocalCollectionAnchorReference", "ddex_LocalResourceAnchorReference", "AccessLimitation", "AdministratingRecordCompanyRole", "AllTerritoryCode", "ArtistRole", "AudioCodecType", "BinaryDataType", "BusinessContributorRole", "CalculationType", "CarrierType", "CdProtectionType", "CharacterType", "CodingType", "CollectionType", "CommercialModelType", "CompilationType", "ContainerFormat", "CreationType", "CreativeContributorRole", "CueOrigin", "CueSheetType", "CueUseType", "CurrencyCode", "CurrentTerritoryCode", "DataMismatchResponseType", "DataMismatchStatus", "DataMismatchType", "DdexTerritoryCode", "DeductionRateType", "DeliveryActionType", "DeliveryMessageType", "DeprecatedCurrencyCode", "DeprecatedIsoTerritoryCode", "DigitizationMode", "DisputeReason", "DistributionChannelType", "DpidStatus", "DrmEnforcementType", "DrmPlatformType", "DsrMessageType", "EquipmentType", "ErnMessageType", "ErncFileStatus", "ErncProposedActionType", "ExpressionType", "ExternallyLinkedResourceType", "FileStatus", "FingerprintAlgorithmType", "GoverningAgreementType", "HashSumAlgorithmType", "ImageCodecType", "ImageType", "InvoiceAvailabilityStatus", "IsoCurrencyCode", "IsoLanguageCode", "IsoTerritoryCode", "LabelNameType", "LicenseOrClaimRefusalReason", "LicenseOrClaimRequestUpdateReason", "LicenseOrClaimUpdateReason", "LicenseRejectionReason", "LicenseStatus", "LicensingProcessStatus", "LodFileStatus", "LodProposedActionType", "MembershipType", "MessageActionType", "MessageContentRevenueType", "MessageContextType", "MessageControlType", "MidiType", "MlcMessageType", "MusicalWorkContributorRole", "MusicalWorkRightsClaimType", "MusicalWorkType", "MwlCaCMessageInBatchType", "MwnMessageType", "NewReleaseMessageStatus", "OperatingSystemType", "OrderType", "PLineType", "ParentalWarningType", "PartyRelationshipType", "PercentageType", "PriceInformationType", "PriceRangeType", "PriceType", "Priority", "ProductType", "ProjectContributorRelationshipType", "Purpose", "RateModificationType", "RatingAgency", "ReasonType", "RecipientRevenueType", "RecordingMode", "RedeliveryReasonType", "ReferenceUnit", "RelationalRelator", "ReleaseAvailabilityStatus", "ReleaseRelationshipType", "ReleaseResourceType", "ReleaseType", "ReportFormat", "ReportType", "RequestReason", "RequestedActionType", "ResourceContributorRole", "ResourceOmissionReason", "ResourceType", "RevenueSourceType", "RightShareRelationshipType", "RightShareType", "RightsClaimPolicyType", "RightsControllerRole", "RightsControllerType", "RightsCoverage", "RoyaltyRateCalculationType", "RoyaltyRateType", "SalesReportAvailabilityStatus", "Sex", "SheetMusicCodecType", "SheetMusicType", "SoftwareType", "SoundProcessorType", "SoundRecordingType", "SupplyChainStatus", "TaxScope", "TaxType", "TerritoryCodeType", "TerritoryCodeTypeIncludingDeprecatedCodes", "TextCodecType", "TextType", "ThemeType", "TisTerritoryCode", "TitleType", "TrackContributorRelationshipType", "UnitOfBitRate", "UnitOfConditionValue", "UnitOfExtent", "UnitOfFrameRate", "UnitOfFrequency", "UpdateIndicator", "UseType", "UserInterfaceType", "ValueType", "VideoCodecType", "VideoContentType", "VideoDefinitionType", "VideoType", "VisualPerceptionType", "VocalType", "WsMessageStatus", "TerritoryCode"]
  end
end # describe XsdReader::Schema
