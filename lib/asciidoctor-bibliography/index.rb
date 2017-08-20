require 'asciidoctor/attribute_list'

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
      lines = []
      bibliographer.occurring_keys.each_with_index do |target, index|
        lines << render_entry(target, bibliographer.index_formatter)
      end

      # Intersperse the lines with empty ones.
      lines.join("\n\n").lines.map(&:strip)
    end

    def render_entry_id(target)
      ['bibliography', target].compact.join('-')
    end

    def render_entry_label(target, formatter)
      Helpers.html_to_asciidoc formatter.render(:bibliography, id: target).join
    end

    def render_entry(target, formatter)
      "anchor:#{render_entry_id(target)}[]#{render_entry_label(target, formatter)}"
    end
  end
end

