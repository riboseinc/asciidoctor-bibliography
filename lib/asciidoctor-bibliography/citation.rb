require "securerandom"
require_relative "formatter"
require_relative "citation_item"

require "csl/styles"

module AsciidoctorBibliography
  class Citation
    TEX_MACROS = %w[citet citet* citealt citealt* citep citep* citealp citealp*
                    citeauthor citeauthor* citeyear citeyearpar].freeze

    MACRO_NAME_REGEXP = TEX_MACROS.dup.concat(%w[cite fullcite]).
      map { |s| Regexp.escape s }.join("|").freeze

    REGEXP = /
      \\?  (#{MACRO_NAME_REGEXP})                # macro name
      (
        (?:   :  (?:\S*?)  \[(?:|.*?[^\\])\]  )  # first target with attributes list
        (?:  \+  (?:\S*?)  \[(?:|.*?[^\\])\]  )* # other targets with wttributes lists
      )
    /x

    MACRO_PARAMETERS_REGEXP = /
      \G                # restart metching from here
      (?:
        [:+]            # separator
        (\S*?)          # optional target
        \[(|.*?[^\\])\] # attributes list
      )
    /x

    REF_ATTRIBUTES = %i[chapter page section clause].freeze

    MISSING_ID_MARK = "*??*".freeze

    attr_reader :macro, :citation_items

    def initialize(macro, *target_and_attributes_list_pairs)
      @uuid = SecureRandom.uuid
      @macro = macro
      @citation_items = []
      target_and_attributes_list_pairs.each do |target, attribute_list|
        @citation_items << CitationItem.new do |cite|
          cite.target = target.to_s.empty? ? "default" : target
          cite.parse_attribute_list attribute_list
        end
      end
      # rubocop:enable Performance/HashEachMethods
    end

    def missing_ids(bibliographer)
      m_ids = (@citation_items.map(&:key) - bibliographer.database.map { |entry| entry["id"] })
      m_ids.map! { |id| id.nil? ? "" : id }
    end

    def any_missing_id?(bibliographer)
      # NOTE: do not use :any? since it ignores nil
      not missing_ids(bibliographer).empty?
    end

    def render(bibliographer)
      # NOTE: If there is any blank key we must render the entire (possibly composite)
      # NOTE: citation as missing, as we don't have that kind of control over CSL styles.
      if any_missing_id?(bibliographer)
        warn "Warning: I didn't find a database entry for #{missing_ids(bibliographer)}."
        # TODO: It would be cool to have the title attribute show the missing keys
        # TODO: as a popup above *??* but it does not work on inline quoted text.
        return MISSING_ID_MARK
      end

      formatted_citation = render_with_csl(bibliographer)
      wrap_up_citation citation: formatted_citation, bibliographer: bibliographer
    end

    def render_with_csl(bibliographer)
      case macro
      when "cite"
        render_citation_with_csl(bibliographer)
      when "fullcite"
        render_fullcite_with_csl(bibliographer)
      when *TEX_MACROS
        render_texmacro_with_csl(bibliographer)
      end
    end

    def wrap_up_citation(citation:, bibliographer:)
      text = citation.dup
      # TODO: handle hyperlinks here, maybe?
      text = ["+++", text, "+++"].join if bibliographer.options.passthrough?(:citation)
      text.prepend "{empty}" if bibliographer.options.prepend_empty?(:citation)
      text
    end

    def render_texmacro_with_csl(bibliographer)
      filename = ["tex", macro.tr("*", "s"), bibliographer.options.tex_style].join("-")
      filepath = File.join AsciidoctorBibliography.root, "lib/csl/styles", filename
      render_citation_with_csl(bibliographer, style: filepath, tex: true)
    end

    def render_fullcite_with_csl(bibliographer)
      formatter = Formatter.new(bibliographer.options.style, locale: bibliographer.options.locale)
      prepare_fullcite_item bibliographer, formatter
      formatter.render(:bibliography, id: citation_items.first.key).join
    end

    def prepare_fullcite_item(bibliographer, formatter)
      formatter.import([bibliographer.database.find_entry_by_id(citation_items.first.key)])
    end

    def render_citation_with_csl(bibliographer, style: bibliographer.options.style, tex: false)
      formatter = Formatter.new(style, locale: bibliographer.options.locale)
      items = prepare_items bibliographer, formatter, tex: tex
      formatted_citation = formatter.engine.renderer.render(items, formatter.engine.style.citation)
      interpolate_formatted_citation! formatted_citation
      formatted_citation
    end

    def interpolate_formatted_citation!(formatted_citation)
      citation_items.each do |citation_item|
        key = Regexp.escape citation_item.key
        formatted_citation.gsub!(/___#{key}___(?<citation>.*?)___\/#{key}___/) do
          # NOTE: this handles custom citation text (slight overkill but easy to extend)
          # NOTE: escaping ] is necessary to safely nest macros (e.g. citing in a footnote)
          (citation_item.text || "{cite}").
            sub("{cite}", Regexp.last_match[:citation].gsub("]", "&rsqb;"))
        end
      end
    end

    def prepare_items(bibliographer, formatter, tex: false)
      # NOTE: when we're using our custom TeX CSL styles prefix/suffix are used as
      #   variables for metadata instead of as parameters for citations.
      cites_with_local_attributes = citation_items.map { |cite| prepare_metadata bibliographer, cite, affix: tex }
      formatter.import cites_with_local_attributes
      formatter.force_sort!(mode: :citation)
      formatter.data.map(&:cite).each { |item| prepare_item bibliographer.options, item, affix: !tex }
    end

    def prepare_metadata(bibliographer, cite, affix: false)
      bibliographer.database.find_entry_by_id(cite.key).
        merge 'citation-number': bibliographer.appearance_index_of(cite.target, cite.key),
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
      id = xref_id "bibliography", ci.target, item.id
      wrap_item item, "___#{item.id}___", "___/#{item.id}___"
      wrap_item item, "<<#{id},", ">>" if options.hyperlinks?
      item.label, item.locator = ci.locator
    end

    def wrap_item(item, prefix, suffix)
      item.prefix = prefix.to_s + item.prefix.to_s
      item.suffix = item.suffix.to_s + suffix.to_s
    end

    def uuid
      ":#{@uuid}:"
    end

    def xref_id(*fragments)
      fragments.compact.join("-")
    end
  end
end
