# XsdReader

XsdReader provides easy and flexible access to XSD information

## Installation


Rubygems:

`
gem install xsd-reader
`

Bundler: 

`
gem 'xsd-reader'
`

## Examples

Load xsd
```ruby
reader = XsdReader::XML.new(:xsd_file => 'ddex-ern-v36.xsd')
```

Get elements and their child elements
```ruby
node = reader['NewReleaseMessage']
node.elements.map(&:name) # => ['MessageHeader', 'UpdateIndicator', 'IsBackfill', 'CatalogTransfer', 'WorkList', 'CueSheetList', 'ResourceList', 'CollectionList', 'ReleaseList', 'DealList']
```

Get attributes
```ruby
reader['NewReleaseMessage']['MessageHeader'].attributes.map(&:name) # => ['LanguageAndScriptCode']
```

Get type information of attribute
```ruby
attribute = reader['NewReleaseMessage']['MessageHeader']['@LanguageAndScriptCode']
attribute.type 				# => 'xs:string'
attribute.type_name			# => 'string'
attribute.type_namespace	# => 'xs'
```

Get element amount details
```ruby
node = @reader['NewReleaseMessage']['ResourceList']['SoundRecording']
node.min_occurs			# => 0
node.max_occurs			# => :unbouded
node.multiple_allowed? # true
node.required?			# false
node = @reader['NewReleaseMessage']['MessageHeader']
node.min_occurs			# => nil
node.max_occurs			# => nil
node.multiple_allowed? # false
node.required?			# true
```


