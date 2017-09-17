require "securerandom"
require_relative "formatters/csl"
require_relative "formatters/tex"
require_relative "citation_item"

module AsciidoctorBibliography
  class Citation
    MACRO_NAME_REGEXP = Formatters::TeX::MACROS.keys.concat(%w[cite fullcite]).
      map { |s| Regexp.escape s }.join("|").freeze
    REGEXP = /\\?(#{MACRO_NAME_REGEXP}):(?:(\S*?)?\[(|.*?[^\\])\])(?:\+(\S*?)?\[(|.*?[^\\])\])*/
    # REF_ATTRIBUTES = %i[chapter page section clause].freeze

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
      if macro == "cite"
        render_citation_with_csl(bibliographer)
      elsif macro == "fullcite"
        render_fullcite_with_csl(bibliographer)
      elsif Formatters::TeX::MACROS.keys.include? macro
        formatter = Formatters::TeX.new(bibliographer.options["citation-style"])
        formatter.import bibliographer.database
        formatter.render(bibliographer, self)
      end
    end

    def render_citation_with_csl(bibliographer)
      formatter = Formatters::CSL.new(bibliographer.options.style)

      cites_with_local_attributes = citation_items.map { |cite| prepare_cite_metadata bibliographer, cite }
      formatter.import cites_with_local_attributes
      formatter.sort(mode: :citation)
      items = formatter.data.map(&:cite)
      items.each { |item| prepare_citation_item bibliographer.options, item }

      formatted_citation = formatter.engine.renderer.render(items, formatter.engine.style.citation)
      # We prepend an empty interpolation to avoid interferences w/ standard syntax (e.g. block role is "\n[foo]")
      "{empty}" + formatted_citation.gsub(/{{{(?<xref_label>.*?)}}}/) do
        # We escape closing square brackets inside the xref label.
        ["[", Regexp.last_match[:xref_label].gsub("]", '\]'), "]"].join
      end
    end

    def prepare_cite_metadata(bibliographer, cite)
      bibliographer.database.find_entry_by_id(cite.key)
        merge('citation-number': bibliographer.appearance_index_of(cite.key)).
        merge('citation-label': cite.key). # TODO: smart label generators
        merge('locator': cite.locator.nil? ? nil : " ")
      # TODO: why is a non blank 'locator' necessary to display locators set at a later stage?
    end

    def prepare_citation_item(options, item)
      # TODO: hyperlink, suppress_author and only_author options

      ci = citation_items.detect { |c| c.key == item.id }
      # Add prefix and suffix
      item.prefix = ci.prefix.to_s + item.prefix.to_s
      item.suffix = item.suffix.to_s + ci.suffix.to_s
      # Wrap into hyperlink
      if options.hyperlinks?
        item.prefix = "xref:#{xref_id(item.id)}{{{" + item.prefix.to_s
        item.suffix = item.suffix.to_s + "}}}"
      end
      # Assign locator.
      item.label, item.locator = ci.locator
    end

    def render_fullcite_with_csl(bibliographer)
      formatter = Formatters::CSL.new(bibliographer.options.style)

      # NOTE: being able to overwrite a more general family of attributes would be neat.
      # mergeable_attributes = Helpers.slice(citation_items.first.named_attributes || {}, *REF_ATTRIBUTES.map(&:to_s))
      # reject empty values
      # mergeable_attributes.reject! do |_key, value|
      #   value.blank?
      # end
      database_entry = bibliographer.database.find_entry_by_id(citation_items.first.key)
      # database_entry.merge!(mergeable_attributes)
      formatter.import([database_entry])

      "{empty}" + Helpers.html_to_asciidoc(formatter.render(:bibliography, id: citation_items.first.key).join)
    end

    def uuid
      ":#{@uuid}:"
    end

    def xref_id(key)
      ["bibliography", key].compact.join("-")
    end

    def xref(key, label)
      "xref:#{xref_id(key)}[#{label.gsub(']', '\]')}]"
    end
  end
end
