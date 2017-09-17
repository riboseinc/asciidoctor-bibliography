module AsciidoctorBibliography
  module Formatters
    # This formatter emulates the behaviour of traditional Bib(La)TeX/NatBib citations.
    class TeX
      MACROS = {
        # NOTE: \citet is equivalent to \cite, so we reserve the latter for CSL styling.
        "citet"       => { type: :textual,       bracketed: true,  authors: :abbreviated },
        "citet*"      => { type: :textual,       bracketed: true,  authors: :full },
        "citealt"     => { type: :textual,       bracketed: false, authors: :abbreviated },
        "citealt*"    => { type: :textual,       bracketed: false, authors: :full },
        "citep"       => { type: :parenthetical, bracketed: true,  authors: :abbreviated },
        "citep*"      => { type: :parenthetical, bracketed: true,  authors: :full },
        "citealp"     => { type: :parenthetical, bracketed: false, authors: :abbreviated },
        "citealp*"    => { type: :parenthetical, bracketed: false, authors: :full },
        "citeauthor"  => { type: :authors_only,  bracketed: false, authors: :abbreviated },
        "citeauthor*" => { type: :authors_only,  bracketed: false, authors: :full },
        "citeyear"    => { type: :years_only,    bracketed: false },
        "citeyearpar" => { type: :years_only,    bracketed: true },
      }.freeze

      attr_accessor :opening_bracket,
                    :closing_bracket,
                    :cites_separator,
                    :style,
                    :author_year_separator,
                    :years_separator

      def initialize(format)
        if format == "numbers"
          bibpunct = "{[}{]}{,}{n}{,}{,}"
        elsif format == "authoryear"
          bibpunct = "{(}{)}{;}{a}{,}{,}"
        else
          raise StandardError, "Unknown TeX citation format: #{format}"
        end
        @opening_bracket,
        @closing_bracket,
        @cites_separator,
        @style,
        @author_year_separator,
        @years_separator = bibpunct.scan(/{.*?}/).map { |s| s[1..-2] }
      end

      def import(database)
        @database = database
      end

      def render(bibliographer, citation)
        macro_options = MACROS[citation.macro]
        output = []
        case macro_options[:type]
        # NOTE: deliberately repetitive to improve redability.
        when :textual
          citation.citation_items.each do |cite|
            authors = authors(macro_options[:authors], cite)
            year = if @style == "n"
                     bibliographer.appearance_index_of(cite.key)
                   else
                     year(cite)
                   end
            cetera = Helpers.join_nonempty([year].concat(extra(cite)), @years_separator + " ")
            cetera = bracket(cetera) if macro_options[:bracketed]
            label = Helpers.join_nonempty([authors, cetera], " ")
            output << citation.xref(cite.key, label)
          end
          output = output.join(@cites_separator + " ")
        when :parenthetical
          citation.citation_items.each do |cite|
            if @style == "n"
              authors = nil
              year = bibliographer.appearance_index_of(cite.key)
            else
              authors = authors(macro_options[:authors], cite)
              year = year(cite)
            end
            cetera = Helpers.join_nonempty([year].concat(extra(cite)), @years_separator + " ")
            label = Helpers.join_nonempty([authors, cetera], @author_year_separator + " ")
            output << citation.xref(cite.key, label)
          end
          output = output.join(@cites_separator + " ")
          output = bracket(output) if macro_options[:bracketed]
        when :authors_only
          citation.citation_items.each do |cite|
            authors = authors(macro_options[:authors], cite)
            year = nil
            cetera = Helpers.join_nonempty([year].concat(extra(cite)), @years_separator + " ")
            label = Helpers.join_nonempty([authors, cetera], @author_year_separator + " ")
            output << citation.xref(cite.key, label)
          end
          output = output.join(@cites_separator + " ")
          output = bracket(output) if macro_options[:bracketed]
        when :years_only
          citation.citation_items.each do |cite|
            authors = nil
            year = year(cite)
            cetera = Helpers.join_nonempty([year].concat(extra(cite)), @years_separator + " ")
            label = Helpers.join_nonempty([authors, cetera], @author_year_separator + " ")
            output << citation.xref(cite.key, label)
          end
          output = output.join(@cites_separator + " ")
          output = bracket(output) if macro_options[:bracketed]
        else
          raise StandardError, "Unknown TeX citation macro type: #{macro_options[:type]}"
        end

        output
      end

      private

      def bracket(string)
        [@opening_bracket, string, @closing_bracket].compact.join
      end

      def find_entry(key)
        entry = @database.detect { |h| h["id"] == key }
        raise StandardError, "Can't find entry: #{key}" if entry.nil?
        entry
      end

      def year(cite)
        entry = find_entry(cite.key)
        issued = entry["issued"]

        if issued.nil?
          warn "asciidoctor-bibliography: citation (#{cite.key}) has no 'issued' information"
          return ""
        end

        date_parts = issued["date-parts"]
        return "" if date_parts.nil?

        return "" if date_parts.first.nil?
        date_parts.first.first
      end

      def extra(cite)
        na = cite.named_attributes
        extra = []
        return extra if na.nil?

        Citation::REF_ATTRIBUTES.each do |sym|
          next if na[sym.to_s].nil?
          extra << ref_content(sym, na[sym.to_s])
        end

        extra
      end

      # TODO: should this be configurable?
      # TODO RT: Yes, and i18n!
      def ref_content(sym, content)
        "#{sym.to_s.capitalize} #{content}"
      end

      def authors(mode, cite)
        case mode
        when :full
          authors_full(cite)
        when :abbreviated
          authors_abbreviated(cite)
        else
          raise StandardError, "Unknown TeX citation authors mode: #{mode}"
        end
      end

      def authors_list(cite)
        entry = find_entry(cite.key)
        authors = entry["author"]
        return [] if authors.nil?
        authors.map { |h| h["family"] }.compact
      end

      def authors_abbreviated(cite)
        authors = authors_list(cite)
        return "" if authors.empty?
        authors.length > 1 ? "#{authors.first} et al." : authors.first
      end

      def authors_full(cite)
        authors = authors_list(cite)
        return "" if authors.empty?
        Helpers.to_sentence authors
      end
    end
  end
end
