# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'locabulary/version'

Gem::Specification.new do |spec|
  spec.name          = "locabulary"
  spec.version       = Locabulary::VERSION
  spec.authors       = ["Jeremy Friesen", "LaRita Robinson"]
  spec.email         = ["jeremy.n.friesen@gmail.com", "LaRita.Robinson@nd.edu"]

  spec.summary       = 'An extraction of limited localized vocabulary for Sipity and CurateND.'
  spec.description   = 'An extraction of limited localized vocabulary for Sipity and CurateND.'
  spec.homepage      = "https://github.com/ndlib/locabulary"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.license = 'APACHE2'

  spec.add_dependency "json"
  spec.add_dependency "dry-configurable"
  spec.add_dependency "activesupport", '>= 4.0', "< 6.0"

  spec.add_development_dependency "dry-schema", ">= 0.4"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-its"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rubocop", '~> 0.49.0'
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "codeclimate-test-reporter", '1.0.3'
  spec.add_development_dependency "fasterer"
  spec.add_development_dependency "shoulda-matchers"
  spec.add_development_dependency "nokogiri"
end
