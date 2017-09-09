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
      filtered_db = bibliographer.occurring_keys
                      .map { |id| bibliographer.database.find { |h| h['id'] == id } }
                      .map { |entry| prepare_entry_metadata bibliographer, entry }
      formatter.import filtered_db
      formatter.sort(mode: :bibliography)

      lines = []
      formatter.bibliography.each_with_index do |reference, index|
        line = '{empty}'
        line << "anchor:#{anchor_id(formatter.data[index].id)}[]"
        line << Helpers.html_to_asciidoc(reference)
        lines << line
      end

      # Intersperse the lines with empty ones to render as paragraphs.
      lines.join("\n\n").lines.map(&:strip)
    end

    def prepare_entry_metadata(bibliographer, entry)
      entry
        .merge('citation-number': bibliographer.appearance_index_of(entry['id']))
        .merge('citation-label': entry['id']) # TODO: smart label generators
    end

    def anchor_id(target)
      ['bibliography', target].compact.join('-')
    end

    def render_entry_label(target, formatter)
      Helpers.html_to_asciidoc formatter.render(:bibliography, id: target).join
    end

    def render_entry(target, formatter)
      "anchor:#{anchor_id(target)}[]#{render_entry_label(target, formatter)}"
    end
  end
end

