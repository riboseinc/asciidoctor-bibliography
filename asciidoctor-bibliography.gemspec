# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'asciidoctor-bibliography/version'

Gem::Specification.new do |spec|
  spec.name          = 'asciidoctor-bibliography'
  spec.version       = AsciidoctorBibliography::VERSION
  spec.authors       = ['Ribose Inc.']
  spec.email         = ['open.source@ribose.com']

  spec.summary       = 'Citations and bibliography the "asciidoctor-way"'
  spec.description   = <<~END
    asciidoctor-bibliography lets you handle citations and bibliography the "asciidoctor-way"!

    Its syntax is designed to be native-asciidoctor:
    * single cite `cite:[key]`;
    * contextual cite `cite[key, page=3]`;
    * multiple cites `cite:[key1]+[key2]`;
    * full cite `fullcite:[key]`; and
    * TeX-compatible macros including `citep:[key]`, `citet:[]key` and friends.

    Citation output styles are fully bridged to the CSL library, supporting formats such as IEEE, APA, Chicago, DIN and ISO 690.

    The `bibliography:[]` command generates a full reference list that adheres to your configured citation style.
END
  spec.homepage      = 'https://github.com/riboseinc/asciidoctor-bibliography'
  spec.license       = 'MIT'

  spec.require_paths = ['lib']
  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {spec}/*`.split("\n")
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.add_dependency 'asciidoctor'
  spec.add_dependency 'citeproc-ruby'
  spec.add_dependency 'csl-styles', '~> 1'
  spec.add_dependency 'latex-decode', '~> 0.2'
  spec.add_dependency 'bibtex-ruby'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'rubocop'
end
