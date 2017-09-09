require 'securerandom'
require 'asciidoctor/attribute_list'
require_relative 'formatters/csl'
require_relative 'formatters/tex'

module AsciidoctorBibliography
  class Cite
    attr_accessor :key, :appearance_index, :target, :positional_attributes, :named_attributes, :locators

    def initialize
      yield self if block_given?
    end

    def locators
      Helpers
        .slice(named_attributes || {}, *CiteProc::CitationItem.labels.map(&:to_s))
        .reject! { |_, value| value.nil? || value.empty? } # equivalent to Hash#compact
    end
  end

  class Citation
    TEX_MACROS_NAMES = Formatters::TeX::MACROS.keys.map { |s| Regexp.escape s }.concat(['fullcite']).join('|')
    REGEXP = /\\?(#{TEX_MACROS_NAMES}):(?:(\S*?)?\[(|.*?[^\\])\])(?:\+(\S*?)?\[(|.*?[^\\])\])*/
    REF_ATTRIBUTES = %i[chapter page section clause].freeze

    attr_reader :macro, :cites

    def initialize(macro, *targets_and_attributes_list)
      @uuid = SecureRandom.uuid
      @macro = macro
      @cites = []
      targets_and_attributes_list.compact.each_slice(2).each do |target, attributes|
        positional_attributes, named_attributes = parse_attributes attributes
        positional_attributes = positional_attributes.values
        @cites << Cite.new do |cite|
          cite.key = positional_attributes.first
          cite.target = target
          cite.positional_attributes = positional_attributes
          cite.named_attributes = named_attributes
        end
      end
    end

    def parse_attributes(attributes)
      ::Asciidoctor::AttributeList.new(attributes).parse
                                  .group_by { |hash_key, _| hash_key.is_a? Integer }
                                  .values.map { |a| Hash[a] }
    end

    def render(bibliographer)
      if macro == 'cite'
        render_citation_with_csl(bibliographer)
      elsif macro == 'fullcite'
        render_fullcite_with_csl(bibliographer)
      elsif Formatters::TeX::MACROS.keys.include? macro
        formatter = Formatters::TeX.new(bibliographer.options['citation-style'])
        formatter.import bibliographer.database
        formatter.render(self)
      end
    end

    def render_citation_with_csl(bibliographer)
      formatter = Formatters::CSL.new(bibliographer.options['reference-style'])

      cites_with_local_attributes = cites.map { |cite| prepare_cite_metadata bibliographer, cite }
      formatter.import cites_with_local_attributes
      formatter.sort(mode: :citation)
      items = formatter.data.map(&:cite)
      items.each { |item| prepare_citation_item item }

      formatted_citation = formatter.engine.renderer.render(items, formatter.engine.style.citation)
      # We prepend an empty interpolation to avoid interferences w/ standard syntax (e.g. block role is "\n[foo]")
      '{empty}' + formatted_citation.gsub(/{{{(?<xref_label>.*?)}}}/) do
        # We escape closing square brackets inside the xref label.
        ['[', Regexp.last_match[:xref_label].gsub(']', '\]'), ']'].join
      end
    end

    def prepare_cite_metadata(bibliographer, cite)
      bibliographer.database.find { |e| e['id'] == cite.key }
                   .merge('citation-number': cite.appearance_index)
                   .merge('citation-label': cite.key) # TODO: smart label generators
                   .merge('locator': cite.locators.any? ? ' ' : nil)
      # TODO: why is 'locator' necessary to display locators? (and not just in the item, later)
    end

    def prepare_citation_item(item)
      # Wrap into hyperlink
      item.prefix = "xref:#{render_xref_id(item.id)}{{{" + item.prefix.to_s
      item.suffix = item.suffix.to_s + '}}}'
      # Assign locator
      locator = cites.find { |cite| cite.key == item.id }.locators.first
      item.label, item.locator = locator unless locator.nil?
      # TODO: suppress_author and only_author options?
    end

    def render_fullcite_with_csl(bibliographer)
      formatter = Formatters::CSL.new(bibliographer.options['reference-style'])

      # NOTE: being able to overwrite a more general family of attributes would be neat.
      mergeable_attributes = Helpers.slice(cites.first.named_attributes || {}, *REF_ATTRIBUTES.map(&:to_s))

      # reject empty values
      mergeable_attributes.reject! do |_key, value|
        value.nil? || value.empty?
      end
      # TODO: as is, cites other than the first are simply ignored.
      database_entry = bibliographer.database.find { |e| e['id'] == cites.first.key }
      database_entry.merge!(mergeable_attributes)
      formatter.import([database_entry])
      '{empty}' + Helpers.html_to_asciidoc(formatter.render(:bibliography, id: cites.first.key).join)
      # '{empty}' + Helpers.html_to_asciidoc(formatter.render(:citation, id: cites.first.key))
    end

    def uuid
      ":#{@uuid}:"
    end

    def keys
      @cites.map(&:key)
    end

    def xref(key, label)
      "xref:#{render_xref_id(key)}[#{label.gsub(']', '\]')}]"
    end

    def render_xref_id(key)
      ['bibliography', key].compact.join('-')
    end

    private

    def render_label(formatter, key)
      formatter.render(:citation, id: key)
    end

    def render_xref(formatter, key)
      "xref:#{render_xref_id(key)}[#{render_label(formatter, key)}]"
    end
  end
end
