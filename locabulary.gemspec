# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'locabulary'

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

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency "json", "~> 1.8"
end
