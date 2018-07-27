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

  spec.add_dependency "json"
  spec.add_dependency "dry-configurable"
  spec.add_dependency "activesupport", '>= 4.0', "< 6.0"

  spec.add_development_dependency "dry-validation"
  # Attempted to update dry-logic without dependency, ran rspec and got the following
  # NoMethodError:
  #  undefined method `curry' for #<Method: Module(Dry::Logic::Predicates::Methods)#type?>
  if RUBY_VERSION =~ /\A2\.[0|1]/
    spec.add_development_dependency "dry-logic", "~> 0.3.0"
  else
    spec.add_development_dependency "dry-logic"
  end
  spec.add_development_dependency "dry-types"
  spec.add_development_dependency "dry-container"
  spec.add_development_dependency "dry-equalizer"
  spec.add_development_dependency "dry-monads"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-its"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'google_drive', "2.1.2"
  spec.add_development_dependency 'highline', '1.7.8'
  spec.add_development_dependency "rubocop", '~> 0.46.0'
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "codeclimate-test-reporter", '1.0.3'
  spec.add_development_dependency "fasterer"
  spec.add_development_dependency "shoulda-matchers"
  spec.add_development_dependency "nokogiri"
end
