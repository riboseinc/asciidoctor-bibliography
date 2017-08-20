require 'asciidoctor'

require_relative '../helpers'
require_relative '../formatters/csl'
require_relative '../formatters/tex'
require_relative '../database'
require_relative '../citation'
require_relative '../index'

module AsciidoctorBibliography
  module Asciidoctor
    class BibliographerPreprocessor < ::Asciidoctor::Extensions::Preprocessor
      def process document, reader

        # We peek at the document attributes we need, without perturbing the parsing flow.
        # NOTE: we're in a preprocessor and they haven't been parsed yet; doing it manually.
        document_attributes =
          ::Asciidoctor::Parser
            .parse(reader, ::Asciidoctor::Document.new, header_only: true)
            .attributes
        # We extract only the ones we recognize.
        document_attributes = Helpers.slice document_attributes, 'bibliography-format', 'bibliography-order', 'bibliography-style', 'bibliography-database'

        # We're handling single database/formatters; generalization will be straightforward when needed.
        document.bibliographer.database = Database.new(document_attributes['bibliography-database'])
        document.bibliographer.index_formatter = Formatters::CSL.new(document_attributes['bibliography-style'])
        document.bibliographer.index_formatter.import document.bibliographer.database
        document.bibliographer.citation_formatter = Formatters::TeX.new(document_attributes['bibliography-format'])
        document.bibliographer.citation_formatter.import document.bibliographer.database

        # Find, store and replace citations with uuids.
        processed_lines = reader.read_lines.map do |line|
          line.gsub(Citation::REGEXP) do
            citation = Citation.new(*Regexp.last_match.captures)
            document.bibliographer.add_citation(citation)
            citation.uuid
          end
        end
        reader = ::Asciidoctor::Reader.new processed_lines

        # NOTE: retrieval and formatting are separated to allow sorting and numeric styles.

        # Find and replace uuids with formatted citations.
        processed_lines = reader.lines.join("\n") # for quicker matching
        document.bibliographer.citations.each do |citation|
          processed_lines.sub!(citation.uuid) do
            citation.render document.bibliographer
          end
        end
        processed_lines = processed_lines.lines.map(&:chomp)
        reader = ::Asciidoctor::Reader.new processed_lines

        # Find and format indices.
        processed_lines = reader.read_lines.map do |line|
          if line =~ Index::REGEXP
            index = Index.new(*Regexp.last_match.captures)
            # document.bibliographer.add_index(index)
            index.render document.bibliographer
          else
            line
          end
        end
        processed_lines.flatten!
        reader = ::Asciidoctor::Reader.new processed_lines
      end
    end
  end
end
