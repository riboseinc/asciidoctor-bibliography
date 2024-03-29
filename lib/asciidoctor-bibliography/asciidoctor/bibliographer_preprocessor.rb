require "asciidoctor"

require_relative "../database"
require_relative "../citation"
require_relative "../index"
require_relative "../options"

module AsciidoctorBibliography
  module Asciidoctor
    class BibliographerPreprocessor < ::Asciidoctor::Extensions::Preprocessor
      def process(document, reader)
        document.bibliographer.options =
          ::AsciidoctorBibliography::Options.build document, reader

        document.bibliographer.database =
          ::AsciidoctorBibliography::Database.new *expand_db_globs(document)

        lines = remove_comments(reader.read_lines)
        processed_lines = process_lines lines, document.bibliographer
        reader.unshift_lines processed_lines
        reader
      end

      private

      def process_lines(lines, bibliographer)
        # First we fetch citations and replace them with uuids,
        lines = fetch_citations lines, bibliographer
        # then we render them
        lines = render_citations lines, bibliographer
        # and finally we render indices.
        render_indices lines, bibliographer
      end

      def remove_comments(lines)
        # Remove block comments
        ls = lines.join("\n").split(/^\/\/\/\/\n/).
          select.with_index { |_, i| i.even? }.join
        # Remove line comments
        ls.split("\n").reject { |line| line.start_with?("//") }
      end

      def fetch_citations(lines, bibliographer)
        lines.join("\n").gsub(Citation::REGEXP) do
          macro_name, macro_pars = Regexp.last_match.captures
          target_and_attributes_list_pairs = macro_pars.scan(Citation::MACRO_PARAMETERS_REGEXP)
          citation = Citation.new(macro_name, *target_and_attributes_list_pairs)
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

      def expand_db_globs(document)
        glob_pattern(
          document.bibliographer.options.database,
          document.base_dir,
        )
      end

      def glob_pattern(pattern_string, base_dir)
        pattern_string.split.map do |pattern|
          Dir.chdir(base_dir) { Dir.glob(normalize_separator(pattern)) }
        end.flatten
      end

      def normalize_separator(path)
        return path if File::ALT_SEPARATOR.nil?
        path.gsub(File::ALT_SEPARATOR, File::SEPARATOR)
      end
    end
  end
end
