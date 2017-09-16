require 'asciidoctor'

require_relative '../helpers'
require_relative '../database'
require_relative '../citation'
require_relative '../index'
require_relative '../options'

module AsciidoctorBibliography
  module Asciidoctor
    class BibliographerPreprocessor < ::Asciidoctor::Extensions::Preprocessor
      def process(document, reader)
        document.bibliographer.options =
          ::AsciidoctorBibliography::Options.new_from_reader reader

        # Load database(s).
        document.bibliographer.database = Database.new(document.bibliographer.options.database)

        # Find, store and replace citations with uuids.
        processed_lines = reader.read_lines.map do |line|
          line.gsub(Citation::REGEXP) do
            citation = Citation.new(*Regexp.last_match.captures)
            document.bibliographer.add_citation(citation)
            citation.uuid
          end
        end
        reader = ::Asciidoctor::Reader.new processed_lines

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
    end
  end
end
