lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "sassinfo/version"

Gem::Specification.new do |spec|
  spec.name          = "sassinfo"
  spec.version       = Sassinfo::VERSION

  spec.authors       = ["Flurin Egger"]
  spec.email         = ["flurin@digitpaint.nl"]
  spec.summary       = "Styleguide plugin for Roger"
  spec.homepage      = "https://github.com/DigitPaint/sassinfo"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "sass", "~> 3.4.0"
  spec.add_dependency "thor"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "mocha", "~> 1.1.0"
  spec.add_development_dependency "test-unit", "~> 3.1.2"
  spec.add_development_dependency "simplecov", "~> 0.10.0"
  spec.add_development_dependency "rubocop", "~> 0.31.0"
end
