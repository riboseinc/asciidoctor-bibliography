require 'securerandom'
require_relative 'formatters/csl'
require_relative 'formatters/tex'
require_relative 'citation_item'

module AsciidoctorBibliography
  class Citation
    TEX_MACROS_NAMES = Formatters::TeX::MACROS.keys.map { |s| Regexp.escape s }.concat(['fullcite']).join('|')
    REGEXP = /\\?(#{TEX_MACROS_NAMES}):(?:(\S*?)?\[(|.*?[^\\])\])(?:\+(\S*?)?\[(|.*?[^\\])\])*/
    REF_ATTRIBUTES = %i[chapter page section clause].freeze

    attr_reader :macro, :citation_items

    def initialize(macro, *target_and_attributes_list_pairs)
      @uuid = SecureRandom.uuid
      @macro = macro
      @citation_items = []
      target_and_attributes_list_pairs.compact.each_slice(2).each do |_target, attribute_list|
        @citation_items << CitationItem.new do |cite|
          # NOTE: we're not doing anything with targets right now.
          # cite.target = _target
          cite.parse_attribute_list attribute_list
        end
      end
    end

    def render(bibliographer)
      if macro == 'cite'
        render_citation_with_csl(bibliographer)
      elsif macro == 'fullcite'
        render_fullcite_with_csl(bibliographer)
      elsif Formatters::TeX::MACROS.keys.include? macro
        formatter = Formatters::TeX.new(bibliographer.options['citation-style'])
        formatter.import bibliographer.database
        formatter.render(bibliographer, self)
      end
    end

    def render_citation_with_csl(bibliographer)
      formatter = Formatters::CSL.new(bibliographer.options['style'])

      cites_with_local_attributes = citation_items.map { |cite| prepare_cite_metadata bibliographer, cite }
      formatter.import cites_with_local_attributes
      formatter.sort(mode: :citation)
      items = formatter.data.map(&:cite)
      items.each { |item| prepare_citation_item item, hyperlink: bibliographer.options['hyperlinks'] == 'true' }

      formatted_citation = formatter.engine.renderer.render(items, formatter.engine.style.citation)
      # We prepend an empty interpolation to avoid interferences w/ standard syntax (e.g. block role is "\n[foo]")
      '{empty}' + formatted_citation.gsub(/{{{(?<xref_label>.*?)}}}/) do
        # We escape closing square brackets inside the xref label.
        ['[', Regexp.last_match[:xref_label].gsub(']', '\]'), ']'].join
      end
    end

    def prepare_cite_metadata(bibliographer, cite)
      bibliographer.database.find { |e| e['id'] == cite.key }
                   .merge('citation-number': bibliographer.appearance_index_of(cite.key))
                   .merge('citation-label': cite.key) # TODO: smart label generators
                   .merge('locator': cite.locators.any? ? ' ' : nil)
      # TODO: why is 'locator' necessary to display locators? (and not just in the item, later)
    end

    def prepare_citation_item(item, hyperlink:)
      # Wrap into hyperlink
      if hyperlink
        item.prefix = "xref:#{xref_id(item.id)}{{{" + item.prefix.to_s
        item.suffix = item.suffix.to_s + '}}}'
      end
      # Assign locator
      locator = citation_items.find { |cite| cite.key == item.id }.locators.first
      item.label, item.locator = locator unless locator.nil?
      # TODO: suppress_author and only_author options?
    end

    def render_fullcite_with_csl(bibliographer)
      formatter = Formatters::CSL.new(bibliographer.options['style'])

      # NOTE: being able to overwrite a more general family of attributes would be neat.
      mergeable_attributes = Helpers.slice(citation_items.first.named_attributes || {}, *REF_ATTRIBUTES.map(&:to_s))

      # reject empty values
      mergeable_attributes.reject! do |_key, value|
        value.nil? || value.empty?
      end
      # TODO: as is, citation items other than the first are simply ignored.
      database_entry = bibliographer.database.find { |e| e['id'] == citation_items.first.key }
      database_entry.merge!(mergeable_attributes)
      formatter.import([database_entry])
      '{empty}' + Helpers.html_to_asciidoc(formatter.render(:bibliography, id: citation_items.first.key).join)
      # '{empty}' + Helpers.html_to_asciidoc(formatter.render(:citation, id: citation_items.first.key))
    end

    def uuid
      ":#{@uuid}:"
    end

    def xref_id(key)
      ['bibliography', key].compact.join('-')
    end

    def xref(key, label)
      "xref:#{xref_id(key)}[#{label.gsub(']', '\]')}]"
    end
  end
end
