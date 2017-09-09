require 'securerandom'
require 'asciidoctor/attribute_list'
require_relative 'formatters/csl'
require_relative 'formatters/tex'

module AsciidoctorBibliography
  class Citation
    TEX_MACROS_NAMES = Formatters::TeX::MACROS.keys.map { |s| Regexp.escape s }.concat(['fullcite']).join('|')
    REGEXP = /\\?(#{TEX_MACROS_NAMES}):(?:(\S*?)?\[(|.*?[^\\])\])(?:\+(\S*?)?\[(|.*?[^\\])\])*/
    REF_ATTRIBUTES = %i[chapter page section clause]

    # No need for a fully fledged class right now.
    Cite = Struct.new(:key, :appearance_index, :target, :positional_attributes, :named_attributes)

    attr_reader :macro, :cites

    def initialize(macro, *targets_and_attributes_list)
      @uuid = SecureRandom.uuid
      @macro = macro
      @cites = []
      targets_and_attributes_list.compact.each_slice(2).each do |target, attributes|
        positional_attributes, named_attributes = # true, false
          ::Asciidoctor::AttributeList.new(attributes).parse
            .group_by { |hash_key, _| hash_key.is_a? Integer }
            .values.map { |a| Hash[a] }
        positional_attributes = positional_attributes.values
        @cites << Cite.new(
          positional_attributes.first,
          nil,
          target,
          positional_attributes,
          named_attributes
        )
      end
    end

    def render(bibliographer)
      if macro == 'cite'
        formatter = Formatters::CSL.new(bibliographer.options['reference-style'])

        cites_with_local_attributes = cites.map do |cite|
          mergeable_attributes =
            Helpers
              .slice(cite.named_attributes || {}, *(REF_ATTRIBUTES.map(&:to_s)))
              .reject! { |key, value| value.nil? || value.empty? }
          bibliographer.database.find { |e| e['id'] == cite.key }
            .merge(mergeable_attributes)
            .merge({'citation-number': cite.appearance_index})
        end

        formatter.import cites_with_local_attributes
        items = formatter.data.map(&:cite)
        items.each do |item|
          item.prefix = "xref:#{render_id(item.id)}{{{"
          item.suffix = "}}}"
          # TODO: locator
        end

        formatted_citation = formatter.engine.renderer.render(items, formatter.engine.style.citation)
        # We prepend an empty interpolation to avoid interferences w/ standard syntax (e.g. block role is "\n[foo]")
        "{empty}" + formatted_citation.gsub(/{{{(?<xref_label>.*?)}}}/) do
          # We escape closing square brackets inside the xref label.
          ['[', Regexp.last_match[:xref_label].gsub(']', '\]'), ']'].join
        end
      elsif macro == 'fullcite'
        formatter = Formatters::CSL.new(bibliographer.options['reference-style'])

        # NOTE: being able to overwrite a more general family of attributes would be neat.
        mergeable_attributes = Helpers.slice(cites.first.named_attributes || {}, *(REF_ATTRIBUTES.map(&:to_s)))

        # reject empty values
        mergeable_attributes.reject! do |key, value|
          value.nil? || value.empty?
        end
        # TODO: as is, cites other than the first are simply ignored.
        database_entry = bibliographer.database.find { |e| e['id'] == cites.first.key }
        database_entry.merge!(mergeable_attributes)
        formatter.import([database_entry])
        '{empty}' + Helpers.html_to_asciidoc(formatter.render(:bibliography, id: cites.first.key).join)
        # '{empty}' + Helpers.html_to_asciidoc(formatter.render(:citation, id: cites.first.key))
      elsif Formatters::TeX::MACROS.keys.include? macro
        formatter = Formatters::TeX.new(bibliographer.options['citation-style'])
        formatter.import bibliographer.database
        formatter.render(self)
      end
    end

    def uuid
      ":#{@uuid}:"
    end

    def keys
      @cites.map { |h| h[:key] }
    end

    def xref(key, label)
      "xref:#{self.render_id(key)}[#{label.gsub(']','\]')}]"
    end

    def render_id(key)
      ['bibliography', key].compact.join('-')
    end

    private

    def render_label(formatter, key)
      formatter.render(:citation, id: key)
    end

    def render_xref(formatter, key)
      "xref:#{render_id(key)}[#{render_label(formatter, key)}]"
    end
  end
end

