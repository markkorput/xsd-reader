require File.dirname(__FILE__) + '/spec_helper'

describe XsdReader::Element do

  let(:reader){
    XsdReader::XML.new(:xsd_file => File.expand_path(File.join(File.dirname(__FILE__), 'examples', 'ddex-v36', 'ddex-ern-v36.xsd')))
  }

  let(:simple_choice_element){
    reader.elements[0]['CatalogTransfer'].complex_type.sequences[0].choices.first
  }

  let(:complex_choice_element){
    reader.elements[0]['ReleaseList', 'Release', 'ReleaseDetailsByTerritory', 'ResourceGroup', 'ResourceContributor'].complex_type.sequences[0].choices.first
  }

  let(:referencing_reader){
    XsdReader::XML.new(:xsd_file => File.expand_path('examples/referencing.xsd', File.dirname(__FILE__)))
  }

  describe 'simple choice groups' do
    it 'gives each group of elements that are part of a choice' do
      choice_group_1 = ['TerritoryCode']
      choice_group_2 = ['ExcludedTerritoryCode']
      child_element_groups = simple_choice_element.elements_and_choices.map{ |choice_group| choice_group.map(&:name) }
      expect(child_element_groups).to eq [choice_group_1, choice_group_2]
    end
  end

  describe 'choice groups with nested sequence' do
    it 'gives each group of elements that are part of a choice' do
      choice_group_1 = ['PartyId']
      choice_group_2 = ['PartyName', 'PartyId']
      child_element_groups = complex_choice_element.elements_and_choices.map{ |choice_group| choice_group.map(&:name) }
      expect(child_element_groups).to eq [choice_group_1, choice_group_2]
    end
  end
end
