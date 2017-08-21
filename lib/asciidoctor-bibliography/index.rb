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
      unsorted_lines = []
      bibliographer.occurring_keys.each_with_index do |target, index|
        line = '{empty}'
        line << "[#{index + 1}] " if bibliographer.options['citation-style'] == 'numbers'
        line << render_entry(target, bibliographer.index_formatter)
        if bibliographer.options['order'] == 'alphabetical'
          sortable_index = first_author_family_name(target, bibliographer)
        elsif bibliographer.options['order'] == 'appearance'
          sortable_index = index
        else # defaults to appearance
          sortable_index = index
        end

        unsorted_lines << { line: line, sortable_index: sortable_index }
      end

      lines = unsorted_lines.sort_by { |l| l[:sortable_index] }.map { |l| l[:line] }

      # Intersperse the lines with empty ones to render as paragraphs.
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

    private

    def first_author_family_name(key, bibliographer)
      authors = bibliographer.database.find{ |h| h['id'] == key }['author']
      return "" if authors.nil?
      authors.map{ |h| h['family'] }.compact.first # TODO: is the first also alphabetically the first?
    end
  end
end

