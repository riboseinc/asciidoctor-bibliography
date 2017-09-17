require "citeproc"
require "csl/styles"
require "yaml"

module AsciidoctorBibliography
  module Formatters
    class CSL < ::CiteProc::Processor
      def initialize(style)
        super style: style, format: :html
      end

      def replace_bibliography_sort(array)
        new_keys = array.map(&::CSL::Style::Sort::Key.method(:new))
        new_sort = ::CSL::Style::Sort.new.add_children(*new_keys)

        bibliography = engine.style.find_child("bibliography")
        bibliography.find_child("sort")&.unlink

        bibliography.add_child new_sort
      end

      def sort(mode:)
        # Valid modes are :citation and :bibliography
        engine.sort! data, engine.style.send(mode).sort_keys if engine.style.send(mode).sort?
      end
    end
  end
end
