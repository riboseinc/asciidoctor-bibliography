require "securerandom"
require_relative "formatters/csl"
require_relative "formatters/tex"
require_relative "citation_item"

require "csl/styles"

module AsciidoctorBibliography
  class Citation
    MACRO_NAME_REGEXP = Formatters::TeX::MACROS.keys.concat(%w[cite fullcite]).
      map { |s| Regexp.escape s }.join("|").freeze
    REGEXP = /\\?(#{MACRO_NAME_REGEXP}):(?:(\S*?)?\[(|.*?[^\\])\])(?:\+(\S*?)?\[(|.*?[^\\])\])*/
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
      case macro
      when "cite"
        render_citation_with_csl(bibliographer)
      when "fullcite"
        render_fullcite_with_csl(bibliographer)
      when *%w[citet citet* citep citep* citealt citealt* citealp citealp*]
        filename = File.join AsciidoctorBibliography.root, "lib/csl/styles/tex-" + macro.tr('*', 's')
        render_citation_with_csl(bibliographer, style: filename, tex: true)
      when *Formatters::TeX::MACROS.keys
        formatter = Formatters::TeX.new(bibliographer.options.tex_style)
        formatter.import bibliographer.database
        formatter.render bibliographer, self
      end
    end

    def render_fullcite_with_csl(bibliographer)
      formatter = Formatters::CSL.new(bibliographer.options.style, locale: bibliographer.options.locale)
      prepare_fullcite_item bibliographer, formatter
      formatted_citation = formatter.render(:bibliography, id: citation_items.first.key).join
      formatted_citation = Helpers.html_to_asciidoc formatted_citation
      # We prepend an empty interpolation to avoid interferences w/ standard syntax (e.g. block role is "\n[foo]")
      "{empty}" + formatted_citation
    end

    def prepare_fullcite_item(bibliographer, formatter)
      formatter.import([bibliographer.database.find_entry_by_id(citation_items.first.key)])
    end

    def render_citation_with_csl(bibliographer, style: bibliographer.options.style, tex: false)
      formatter = Formatters::CSL.new(style, locale: bibliographer.options.locale)
      items = prepare_items bibliographer, formatter, tex: tex
      formatted_citation = formatter.engine.renderer.render(items, formatter.engine.style.citation)
      escape_brackets_inside_xref! formatted_citation
      # We prepend an empty interpolation to avoid interferences w/ standard syntax (e.g. block role is "\n[foo]")
      "{empty}" + formatted_citation
    end

    def escape_brackets_inside_xref!(string)
      string.gsub!(/{{{(?<xref_label>.*?)}}}/) do
        ["[", Regexp.last_match[:xref_label].gsub("]", '\]'), "]"].join
      end
    end

    def prepare_items(bibliographer, formatter, tex: false)
      # NOTE: when we're using our custom TeX CSL styles prefix/suffix are used as
      #   varieables for metadata instead of as parameters for citations.
      cites_with_local_attributes = citation_items.map { |cite| prepare_metadata bibliographer, cite, affix: tex }
      formatter.import cites_with_local_attributes
      formatter.sort(mode: :citation)
      formatter.data.map(&:cite).each { |item| prepare_item bibliographer.options, item, affix: !tex }
    end

    def prepare_metadata(bibliographer, cite, affix: false)
      bibliographer.database.find_entry_by_id(cite.key).
        merge 'citation-number': bibliographer.appearance_index_of(cite.key),
              'citation-label': cite.key, # TODO: smart label generators
              'locator': cite.locator.nil? ? nil : " ",
              'prefix': affix ? cite.prefix : nil,
              'suffix': affix ? cite.suffix : nil
      # TODO: why is a non blank 'locator' necessary to display locators set at a later stage?
    end

    def prepare_item(options, item, affix: true)
      # TODO: hyperlink, suppress_author and only_author options
      ci = citation_items.detect { |c| c.key == item.id }
      wrap_item item, ci.prefix, ci.suffix if affix
      wrap_item item, "xref:#{xref_id(item.id)}{{{", "}}}" if options.hyperlinks?
      item.label, item.locator = ci.locator
    end

    def wrap_item(item, prefix, suffix)
      item.prefix = prefix.to_s + item.prefix.to_s
      item.suffix = item.suffix.to_s + suffix.to_s
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
