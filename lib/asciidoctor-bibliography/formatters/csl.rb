require 'citeproc'
require 'csl/styles'
require 'yaml'

module AsciidoctorBibliography
  module Formatters
    class CSL < ::CiteProc::Processor
      def initialize(style)
        super style: style, format: :html
      end

      def replace_bibliography_sort(hash)
        new_sort_keys = hash.map(&::CSL::Style::Sort::Key.method(:new))
        sort = engine.style > 'bibliography' > 'sort'
        sort.delete_children sort.children
        sort.add_children(*new_sort_keys)
      end

      def sort(mode:)
        # Valid modes are :citation and :bibliography
        engine.sort! data, engine.style.send(mode).sort_keys if engine.style.send(mode).sort?
      end
    end
  end
end
