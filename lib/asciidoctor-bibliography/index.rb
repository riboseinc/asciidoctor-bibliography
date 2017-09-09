require 'asciidoctor/attribute_list'
require_relative 'formatters/csl'

require_relative 'helpers'

module AsciidoctorBibliography
  class Index
    REGEXP = /^(bibliography)::(\S+)?\[(|.*?[^\\])\]$/

    attr_reader :macro, :target, :attributes

    def initialize(macro, target, attributes)
      @macro = macro
      @target = target
      @attributes = ::Asciidoctor::AttributeList.new(attributes).parse
    end

    def render(bibliographer)
      formatter = Formatters::CSL.new(bibliographer.options['reference-style'])
      filtered_db = bibliographer.occurring_keys.map { |id| bibliographer.database.find { |h| h['id'] == id } }
      formatter.import filtered_db

      # Force sorting w/ engine criteria on formatter data.
      #   Same sorting is done in engine to produce formatted bibliography references.
      formatter.engine.sort! formatter.data, formatter.engine.style.bibliography.sort_keys unless !formatter.engine.style.citation.sort?

      lines = []
      formatter.bibliography.each_with_index do |reference, index|
        line = '{empty}'
        line << "anchor:#{render_entry_id(formatter.data[index].id)}[]"
        line << Helpers.html_to_asciidoc(reference)
        lines << line
      end

      # Intersperse the lines with empty ones to render as paragraphs.
      lines.join("\n\n").lines.map(&:strip)
    end

    def render_entry_id(target)
      ['bibliography', target].compact.join('-')
    end

    def render_entry_label(target, formatter)
      # byebug
      Helpers.html_to_asciidoc formatter.render(:bibliography, id: target).join
    end

    def render_entry(target, formatter)
      "anchor:#{render_entry_id(target)}[]#{render_entry_label(target, formatter)}"
    end
  end
end

