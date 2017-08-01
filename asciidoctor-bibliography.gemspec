require File.expand_path('lib/asciidoctor-bibliography/version', File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.name = 'asciidoctor-bibliography'
  s.platform = Gem::Platform::RUBY
  s.author = 'Paolo Brasolin'
  s.version = AsciidoctorBibliography::VERSION
  s.email = 'paolo.brasolin@gmail.com'
  s.homepage = 'https://github.com/riboseinc/asciidoctor-bibliography'
  s.summary = 'Bibliographic references for asciidoc'
  s.license = 'Nonstandard'
  s.description = <<-END
asciidoctor-bibliography adds bibliography support for asciidoc documents by introducing
two new macros: `cite:[KEY]` and `bibliography::[]`. Citations are parsed and
replaced with formatted inline texts, and reference lists are automatically
generated and inserted into where `bibliography::[]` is placed.  The
references are formatted using styles provided by CSL.
END
  # s.files = Dir['lib/**/*'] + ['LICENSE.txt', 'README.md']
  s.required_ruby_version = '~> 2.0'
  s.add_development_dependency('asciidoctor')
  s.add_development_dependency('bibtex-ruby')
  s.add_development_dependency('byebug')
  s.add_development_dependency('citeproc-ruby')
  s.add_development_dependency('csl-styles')
  s.add_development_dependency('latex-decode')

  # s.add_runtime_dependency('bibliography-ruby', "~> 4")
  # s.add_runtime_dependency('citeproc-ruby', "~> 1")
  # s.add_runtime_dependency('csl-styles', '~> 1')
  # s.add_runtime_dependency('latex-decode', '~> 0.2')
end
