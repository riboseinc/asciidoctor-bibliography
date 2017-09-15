require 'asciidoctor'

module AsciidoctorBibliography
  module Options
    PREFIX = 'bibliography-'.freeze

    DEFAULTS = {
      'order' => 'alphabetical',
      'style' => 'apa',
      'citation-style' => 'authoryear',
      'hyperlinks' => 'true',
      'database' => nil,
      'bibliography-sort' => nil
    }.freeze

    def self.get(reader)
      header_attributes = extract_attributes reader
      bibliography_options = filter_attributes header_attributes
      DEFAULTS.merge bibliography_options
    end

    # TODO: what follows should be private

    def self.extract_attributes(reader)
      # We peek at the document attributes we need, without perturbing the parsing flow.
      # NOTE: we'll use this in a preprocessor and they haven't been parsed yet, there.
      tmp_document = ::Asciidoctor::Document.new
      tmp_reader = ::Asciidoctor::PreprocessorReader.new(tmp_document, reader.source_lines)

      ::Asciidoctor::Parser
        .parse(tmp_reader, tmp_document, header_only: true)
        .attributes
    end

    def self.filter_attributes(hash)
      Helpers
        .slice(hash, *DEFAULTS.keys.map { |k| "#{PREFIX}#{k}" })
        .map { |k, v| [k[PREFIX.length..-1], v] }.to_h
        .reject { |_, value| value.nil? || value.empty? }.to_h
    end
  end
end
