require "asciidoctor"

require_relative "../helpers"
require_relative "../database"
require_relative "../citation"
require_relative "../index"
require_relative "../options"

module AsciidoctorBibliography
  module Asciidoctor
    class BibliographerPreprocessor < ::Asciidoctor::Extensions::Preprocessor
      def process(document, reader)
        document.bibliographer.options =
          ::AsciidoctorBibliography::Options.new_from_reader reader

        document.bibliographer.database = Database.new(document.bibliographer.options.database)

        process_reader reader, document.bibliographer
      end

      private

      def process_reader(reader, bibliographer)
        processed_lines = fetch_citations reader.lines, bibliographer
        reader = ::Asciidoctor::Reader.new processed_lines

        processed_lines = render_citations reader.lines, bibliographer
        reader = ::Asciidoctor::Reader.new processed_lines

        processed_lines = render_indices reader.lines, bibliographer
        ::Asciidoctor::Reader.new processed_lines
      end

      def fetch_citations(lines, bibliographer)
        lines.join("\n").gsub!(Citation::REGEXP) do
          citation = Citation.new(*Regexp.last_match.captures)
          bibliographer.add_citation(citation)
          citation.uuid
        end.lines.map(&:chomp)
      end

      def render_citations(lines, bibliographer)
        processed_lines = lines.join("\n")
        bibliographer.citations.each do |citation|
          processed_lines.sub!(citation.uuid) do
            citation.render bibliographer
          end
        end
        processed_lines.lines.map(&:chomp)
      end

      def render_indices(lines, bibliographer)
        lines.map do |line|
          if line =~ Index::REGEXP
            index = Index.new(*Regexp.last_match.captures)
            index.render bibliographer
          else
            line
          end
        end.flatten
      end
    end
  end
end
