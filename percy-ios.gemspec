# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'percy/ios/version'

Gem::Specification.new do |spec|
  spec.name          = 'percy-ios'
  spec.version       = Percy::IOS::VERSION
  spec.authors       = ['Miklós Fazkeas']
  spec.email         = ['mfazekas@szemafor.com']
  spec.summary       = %q{Percy::IOS}
  spec.description   = %q{}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'percy-client', '~> 1.9.0'
  spec.add_dependency 'chunky_png', '~> 1.3.1'
  spec.add_dependency 'plist', '~> 3.2.0'
end