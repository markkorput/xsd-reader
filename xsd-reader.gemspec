Gem::Specification.new do |s|
  s.name = "xsd-reader-fuga"
  s.version = '0.4.1'
  s.files = `git ls-files`.split($/)
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.add_dependency 'nokogiri', '~> 1.6'
  s.add_dependency 'rest-client', '~> 1.8'
  s.add_development_dependency 'rake', '~> 10.1'
  s.add_development_dependency 'rspec', '~> 3.3'

  s.author = "Mark van de Korput"
  s.email = "dr.theman@gmail.com"
  s.date = '2015-08-27'
  s.description = %q{A library of Ruby classes for quick and convenient usage of xsd schemas}
  s.summary = %q{A library of Ruby classes for flexible access of xsd schemas}
  s.homepage = %q{https://github.com/markkorput/xsd-reader}
  s.license = "MIT"
end
