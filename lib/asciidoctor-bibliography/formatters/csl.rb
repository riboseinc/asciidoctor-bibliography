require 'citeproc'
require 'csl/styles'

module AsciidoctorBibliography
  module Formatters
    class CSL < ::CiteProc::Processor
      def initialize(style)
        super style: style, format: :html
      end

      def sort(mode:)
        # Valid modes are :citation and :bibliography
        engine.sort! data, engine.style.send(mode).sort_keys if engine.style.send(mode).sort?
      end
    end
  end
end
