# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'locabulary/version'

Gem::Specification.new do |spec|
  spec.name          = "locabulary"
  spec.version       = Locabulary::VERSION
  spec.authors       = ["Jeremy Friesen"]
  spec.email         = ["jeremy.n.friesen@gmail.com"]

  spec.summary       = %q{An extraction of limited localized vocabulary for Sipity and CurateND.}
  spec.description   = %q{An extraction of limited localized vocabulary for Sipity and CurateND.}
  spec.homepage      = "https://github.com/ndlib/locabulary"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.license = 'APACHE2'

  # spec.add_dependency "json", "~> 1.8"
  # spec.add_dependency "dry-configurable", "~> 0.1.7"
  # spec.add_dependency "activesupport", '>= 4.0', "< 6.0"
  #
  # spec.add_development_dependency "dry-validation", "~> 0.9.5"
  # spec.add_development_dependency "dry-logic", "~> 0.3.0"
  # spec.add_development_dependency "dry-types", "~> 0.8.1"
  # spec.add_development_dependency "dry-container", "~> 0.5.0"
  # spec.add_development_dependency "dry-equalizer", "~> 0.2.0"
  # spec.add_development_dependency "dry-monads", "~> 0.1.1"
  #
  # spec.add_development_dependency "bundler"
  # spec.add_development_dependency "rspec", '3.5.0'
  # spec.add_development_dependency "rspec-its", '1.2.0'
  # spec.add_development_dependency "rake", "~> 10.0"
  # spec.add_development_dependency 'google_drive', "2.1.2"
  # spec.add_development_dependency 'highline', '1.7.8'
  # spec.add_development_dependency "rubocop", '~> 0.46.0'
  # spec.add_development_dependency "simplecov", '0.12.0'
  # spec.add_development_dependency "codeclimate-test-reporter", '1.0.3'
  # spec.add_development_dependency "fasterer", '0.3.2'
  # spec.add_development_dependency "shoulda-matchers", '3.1.1'
  # spec.add_development_dependency "nokogiri"
end
