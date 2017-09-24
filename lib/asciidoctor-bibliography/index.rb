require "asciidoctor/attribute_list"
require_relative "formatter"

require_relative "helpers"

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
      formatter = setup_formatter bibliographer

      lines = []
      formatter.bibliography.each_with_index do |reference, index|
        line = "{empty}"
        line << "anchor:#{anchor_id(formatter.data[index].id)}[]"
        line << Helpers.html_to_asciidoc(reference)
        lines << line
      end

      # Intersperse the lines with empty ones to render as paragraphs.
      lines.join("\n\n").lines.map(&:strip)
    end

    private

    def setup_formatter(bibliographer)
      formatter = Formatter.new(bibliographer.options.style, locale: bibliographer.options.locale)

      formatter.replace_bibliography_sort bibliographer.options.sort unless bibliographer.options.sort.nil?

      filtered_db = prepare_filtered_db bibliographer
      formatter.import filtered_db
      formatter.sort(mode: :bibliography)

      formatter
    end

    def prepare_filtered_db(bibliographer)
      bibliographer.occurring_keys.
        map { |id| bibliographer.database.find_entry_by_id(id) }.
        map { |entry| prepare_entry_metadata bibliographer, entry }
    end

    def prepare_entry_metadata(bibliographer, entry)
      entry.
        merge('citation-number': bibliographer.appearance_index_of(entry["id"])).
        merge('citation-label': entry["id"]) # TODO: smart label generators
    end

    def anchor_id(target)
      ["bibliography", target].compact.join("-")
    end

    def render_entry_label(target, formatter)
      Helpers.html_to_asciidoc formatter.render(:bibliography, id: target).join
    end

    def render_entry(target, formatter)
      "anchor:#{anchor_id(target)}[]#{render_entry_label(target, formatter)}"
    end
  end
end
