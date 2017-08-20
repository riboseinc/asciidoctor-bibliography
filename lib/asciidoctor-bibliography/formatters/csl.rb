require 'citeproc'
require 'csl/styles'

module AsciidoctorBibliography
  module Formatters
    class CSL < ::CiteProc::Processor
      def initialize(style)
        super style: style, format: :html
      end
    end
  end
end
