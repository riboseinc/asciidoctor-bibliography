require 'asciidoctor'

require_relative '../helpers'
require_relative '../formatter'
require_relative '../database'
require_relative '../citation'
require_relative '../index'

module AsciidoctorBibliography
  module Asciidoctor
    class BibliographerPreprocessor < ::Asciidoctor::Extensions::Preprocessor
      def process document, reader

        # We peek at the document attributes we need, without perturbing the parsing flow.
        # NOTE: we're in a preprocessor; they haven't been parsed yet!
        document_attributes =
          ::Asciidoctor::Parser
            .parse(reader, ::Asciidoctor::Document.new, header_only: true)
            .attributes
        document_attributes = Helpers.slice document_attributes, 'bibliography-style', 'bibliography-database'

        # Here we handle only a single database/formatter pair.
        # The future extension will be straightforward.
        document.bibliographer.database = Database.new(document_attributes['bibliography-database'])
        document.bibliographer.formatter = Formatter.new(document_attributes['bibliography-style'])
        document.bibliographer.formatter.import document.bibliographer.database

        # Find, store and format citations.
        processed_lines = reader.read_lines.map do |line|
          line.gsub(Citation::REGEXP) do
            citation = Citation.new(*Regexp.last_match.captures)
            document.bibliographer.citations << citation
            citation.render document.bibliographer.formatter
          end
        end
        reader = ::Asciidoctor::Reader.new processed_lines

        # Find, store and format indices.
        processed_lines = reader.read_lines.map do |line|
          if line =~ Index::REGEXP
            index = Index.new(*Regexp.last_match.captures)
            used_keys = document.bibliographer.citations.map(&:keys).flatten.uniq
            index.render(used_keys, document.bibliographer.formatter)
          else
            line
          end
        end.flatten!
        reader = ::Asciidoctor::Reader.new processed_lines
      end
    end
  end
end
