require File.dirname(__FILE__) + '/spec_helper'

describe XsdReader do

  let(:reader){
    XsdReader::XML.new(:xsd_file => File.expand_path(File.join(File.dirname(__FILE__), 'examples', 'ddex-v36', 'ddex-ern-v36.xsd')))
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

  it "gives all child element definitions for a certain node through the `elements` method" do
    expect(reader.elements.map(&:name)).to eq ['NewReleaseMessage', 'CatalogListMessage']
    expect(reader.elements[0].elements[0].name).to eq 'MessageHeader'
  end

  it "gives a child element object through the square brackets ([]) operator (matching by name)" do
    expect(reader['NewReleaseMessage'].name).to eq 'NewReleaseMessage'
    # this supports linking:
    # byebug
    expect(reader['NewReleaseMessage']['ReleaseList']['Release'].attributes.map(&:name)).to eq ["LanguageAndScriptCode", "IsMainRelease"]
  end

  it "gives a specific element in the hierarchy when passing an array argument to the square brackets ([]) operator" do
    # this supports linking:
    expect(reader[['NewReleaseMessage', 'ResourceList', 'SoundRecording']].name).to eq 'SoundRecording'
    expect(reader[['NewReleaseMessage', 'ResourceList', 'SoundRecording']].multiple_allowed?).to eq true
  end

  it "automatically turns symbol arguments in the square brackets operator ([]) into strings" do
    expect(reader[:NewReleaseMessage].name).to eq 'NewReleaseMessage'
    # this supports linking:
    expect(reader[:NewReleaseMessage]['ReleaseList'][:Release].attributes.map(&:name)).to eq ["LanguageAndScriptCode", "IsMainRelease"]
    expect(reader[:NewReleaseMessage, 'ReleaseList', :Release].attributes.map(&:name)).to eq ["LanguageAndScriptCode", "IsMainRelease"]
  end

  it "should return nil and not raise an exceptions when the square brackets ([]) operator gets invalid input" do
    expect{
      expect(reader[:NewReleaseMessage, 'Nothing', '@Whatever', 'Foo']).to eq nil
    }.to_not raise_error
  end

  it "provides a `child_elements?` convenience method" do
    expect(reader['NewReleaseMessage'].child_elements?).to be true
    expect(reader['NewReleaseMessage']['MessageHeader']['MessageThreadId'].child_elements?).to be false
  end

  it "provides `min_occurs` and `max_occurs` reader methods" do
    expect(reader['NewReleaseMessage']['ResourceList'].min_occurs).to eq nil
    expect(reader['NewReleaseMessage']['ResourceList']['SoundRecording'].min_occurs).to eq 0
    expect(reader['NewReleaseMessage']['ResourceList']['SoundRecording'].max_occurs).to eq :unbounded
  end

  it "provides a boolean `multiple_allowed?` method, indicating if multiple instances of this element are allowed" do
    # byebug
    expect(reader['NewReleaseMessage']['ResourceList'].multiple_allowed?).to be false
    expect(reader['NewReleaseMessage']['ResourceList']['SoundRecording'].multiple_allowed?).to be true
  end

  it "provides a `required?` method, indicating if an element is required to be there" do
    expect(reader['NewReleaseMessage'].required?).to be true
    expect(reader['NewReleaseMessage']['ResourceList'].required?).to be true
    expect(reader['NewReleaseMessage']['CollectionList'].required?).to be false
  end

  it "provides an `optional?` convenience method, as an opposite of `required?`" do
    expect(reader['NewReleaseMessage'].optional?).to be false
    expect(reader['NewReleaseMessage']['ResourceList'].optional?).to be false
    expect(reader['NewReleaseMessage']['CollectionList'].optional?).to be true
  end

  # it "gives an array recursive parent names `ancestors` method" do
  #   skip 'Not yet (properly) imlemented'
  #   # byebug
  #   expect(reader.ancestors).to eq []
  #   expect(reader['NewReleaseMessage'].ancestors).to eq []
  #   expect(reader['NewReleaseMessage']['DealList']['ReleaseDeal'].ancestors.map(&:name)).to eq ['NewReleasMessage', 'DealList']
  # end    

  describe "imports"  do
    it "finds imported types for elements" do
      simple_type = reader['NewReleaseMessage']['DealList']['ReleaseDeal']['Deal']['DealTerms']['WebPolicy']['AccessLimitation'].linked_simple_type
      expect(simple_type.class).to eq XsdReader::SimpleType
      expect(simple_type.name).to eq 'AccessLimitation'
      # byebug
      expect(simple_type.schema).to be reader.imports[0].reader.schema
    end
  end
end
