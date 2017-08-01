require 'citeproc'
require 'csl/styles'

module AsciidoctorBibliography
  class Formatter < ::CiteProc::Processor

    def initialize(style)
      super style: style, format: :html
    end
  end
end
