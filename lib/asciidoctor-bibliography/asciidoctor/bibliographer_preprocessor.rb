require 'asciidoctor'

require_relative '../helpers'
require_relative '../database'
require_relative '../citation'
require_relative '../index'

module AsciidoctorBibliography
  module Asciidoctor
    class BibliographerPreprocessor < ::Asciidoctor::Extensions::Preprocessor
      def process(document, reader)
        set_bibliographer_options(document, reader)

        if document.bibliographer.options['database'].nil?
          warn "No bibliographic database was provided: all bibliographic macros will be ignored. You can set it using the 'bibliography-database' option in the document's preamble."
          return reader
        end

        # Load database(s).
        document.bibliographer.database = Database.new(document.bibliographer.options['database'])

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
        # document.bibliographer.sort

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
            index.render document.bibliographer
          else
            line
          end
        end
        processed_lines.flatten!
        ::Asciidoctor::Reader.new processed_lines
      end

      private

      def set_bibliographer_options(document, reader)
        # We peek at the document attributes we need, without perturbing the parsing flow.
        # NOTE: we're in a preprocessor and they haven't been parsed yet; doing it manually.
        document_attributes =
          ::Asciidoctor::Parser
          .parse(reader, ::Asciidoctor::Document.new, header_only: true)
          .attributes
        defaults = {
          'order' => 'alphabetical',
          'reference-style' => 'chicago-author-date',
          'citation-style' => 'authoryear'
        }
        user = Hash[Helpers.slice(document_attributes, 'bibliography-citation-style', 'bibliography-order', 'bibliography-reference-style', 'bibliography-database').map { |k, v| [k.sub(/^bibliography-/, ''), v] }]
        defaults.each { |k, v| user[k] ||= v }
        document.bibliographer.options = user
      end
    end
  end
end
