# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "asciidoctor-bibliography/version"

Gem::Specification.new do |spec|
  spec.name          = "asciidoctor-bibliography"
  spec.version       = AsciidoctorBibliography::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = "Bibliographic references for asciidoc"
  spec.description   = <<-END
asciidoctor-bibliography adds bibliography support for asciidoc documents by introducing
two new macros: `cite:[KEY]` and `bibliography::[]`. Citations are parsed and
replaced with formatted inline texts, and reference lists are automatically
generated and inserted into where `bibliography::[]` is placed.  The
references are formatted using styles provided by CSL.
END
  spec.homepage      = "https://github.com/riboseinc/asciidoctor-bibliography"
  spec.license       = "MIT"

  spec.require_paths = ["lib"]
  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {spec}/*`.split("\n")
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.add_dependency "asciidoctor"
  spec.add_dependency "citeproc-ruby"
  spec.add_dependency "csl-styles", "~> 1"
  spec.add_dependency "latex-decode", "~> 0.2"
  spec.add_dependency "bibtex-ruby"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "simplecov"
end
