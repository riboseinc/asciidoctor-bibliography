require "asciidoctor/attribute_list"
require_relative "formatter"

module AsciidoctorBibliography
  class Index
    REGEXP = /^(bibliography)::(\S+)?\[(|.*?[^\\])\]$/

    attr_reader :macro, :target, :attributes

    def initialize(macro, target, attributes)
      @macro = macro
      @target = target.to_s.empty? ? "default" : target
      @attributes = ::Asciidoctor::AttributeList.new(attributes).parse
    end

    def render(bibliographer)
      formatter = setup_formatter bibliographer

      lines = []
      formatter.bibliography.each_with_index do |reference, index|
        line = "{empty}"
        id = anchor_id "bibliography", target, formatter.data[index].id
        line << "anchor:#{id}[]"
        line << reference
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
      formatter.force_sort!(mode: :bibliography)

      formatter
    end

    def prepare_filtered_db(bibliographer)
      bibliographer.occurring_keys[target].
        map { |id| bibliographer.database.find_entry_by_id(id) }.
        map { |entry| prepare_entry_metadata bibliographer, entry }
    end

    def prepare_entry_metadata(bibliographer, entry)
      entry.
        merge('citation-number': bibliographer.appearance_index_of(target, entry["id"])).
        merge('citation-label': entry["id"]) # TODO: smart label generators
    end

    def anchor_id(*fragments)
      fragments.compact.join("-")
    end
  end
end
