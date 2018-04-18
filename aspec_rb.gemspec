
# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aspec_rb/version'

Gem::Specification.new do |spec|
  spec.name          = 'aspec_rb'
  spec.version       = AspecRb::VERSION
  spec.authors       = ['tcob']
  spec.email         = ['brian.smith@numberfour.eu']

  spec.summary       = 'Asciidoctor extensions for large HTML documents'
  spec.description   = 'This plugin is a group of Asciidoctor extensions that perform directory walking,
                          resolving the location of titles and anchors in all adoc files so that inter-document
                          cross-references are resolved automatically. Also included are some
                          custom macros and blocks that are useful for techinical writing.'
  spec.homepage      = 'https://github.com/tcob/aspec_rb'
  spec.license       = 'MIT'

  # This gem will work with 2.3 or greater.
  spec.required_ruby_version = '>= 2.3'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'test-unit'
  spec.add_runtime_dependency 'asciidoctor'
end
