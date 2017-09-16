require 'asciidoctor'
require_relative 'errors'
require 'csl/styles'

module AsciidoctorBibliography
  class Options < Hash
    def validate!
    end

    def style
      # Error throwing delegated to CSL library.
      self['style']
    end

    def hyperlinks?
      value = self['hyperlinks']
      unless %w[true false].include? value
        message = "Option :bibliography-hyperlinks: has an invalid value (#{value}). Allowed values are 'true' and 'false'."
        raise Errors::Options::Invalid, message
      end

      value == 'true'
    end

    def database
      value = self['database']
      if value.nil?
        message = 'Option :bibliography-database: is mandatory. A bibliographic database is required.'
        raise Errors::Options::Missing, message
      end

      value
    end

    def sort
      begin
        value = YAML.safe_load self['bibliography-sort'].to_s
      rescue Psych::SyntaxError => psych_error
        message = "Option :bibliography-sort: is not a valid YAML string: \"#{psych_error}\"."
        raise Errors::Options::Invalid, message
      end

      value = self.class.validate_parsed_sort_type! value
      value = self.class.validate_parsed_sort_contents! value unless value.nil?
      value
    end

    PREFIX = 'bibliography-'.freeze

    DEFAULTS = {
      'order' => 'alphabetical',
      'style' => 'apa',
      'citation-style' => 'authoryear',
      'hyperlinks' => 'true',
      'database' => nil,
      'bibliography-sort' => nil
    }.freeze

    def self.new_from_reader(reader)
      new.merge get_options_hash(reader)
    end

    def self.get_options_hash(reader)
      header_attributes = get_header_attributes_hash reader
      bibliography_options = filter_attributes header_attributes
      DEFAULTS
        .merge(bibliography_options)
        .reject { |_, value| value.nil? || value.empty? }.to_h
    end

    def self.get_header_attributes_hash(reader)
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
      # NOTE: at this point valid values are nonempty strings.
    end

    def self.validate_parsed_sort_type!(value)
      return value if value.nil?
      return value if value.is_a?(Array) && value.all { |v| v.is_a? Hash }
      return [value] if value.is_a? Hash
      message = "Option :bibliography-sort: has an invalid value (#{value}). Please refer to manual for more info."
      raise Errors::Options::Invalid, message
    end

    def self.validate_parsed_sort_contents!(array)
      allowed_keys = %w[variable macro sort names-min names-use-first names-use-last]
      return array unless array.any? { |hash| (hash.keys - allowed_keys).any? }
      message = "Option :bibliography-sort: has a value containing invalid keys (#{array}). Allowed keys are #{allowed_keys.inspect}. Please refer to manual for more info."
      raise Errors::Options::Invalid, message
    end
  end
end
