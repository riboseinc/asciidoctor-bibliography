module AsciidoctorBibliography
  module Formatters
    class TeX
      MACROS = {
        # NOTE: cite = citet
        'cite' =>        { type: :textual,       bracketed: true,  authors: :abbreviated },
        'citet' =>       { type: :textual,       bracketed: true,  authors: :abbreviated },
        'citet*' =>      { type: :textual,       bracketed: true,  authors: :full },
        'citealt' =>     { type: :textual,       bracketed: false, authors: :abbreviated },
        'citealt*' =>    { type: :textual,       bracketed: false, authors: :full },
        'citep' =>       { type: :parenthetical, bracketed: true,  authors: :abbreviated },
        'citep*' =>      { type: :parenthetical, bracketed: true,  authors: :full },
        'citealp' =>     { type: :parenthetical, bracketed: false, authors: :abbreviated },
        'citealp*' =>    { type: :parenthetical, bracketed: false, authors: :full },
        'citeauthor' =>  { type: :authors_only,  bracketed: false, authors: :abbreviated },
        'citeauthor*' => { type: :authors_only,  bracketed: false, authors: :full },
        'citeyear' =>    { type: :years_only,    bracketed: false },
        'citeyearpar' => { type: :years_only,    bracketed: true }
      }

      attr_reader :format

      # \bibpunct{(}{)}{;}{a}{,}{,}
      attr_accessor :opening_bracket,
                    :closing_bracket,
                    :cites_separator,
                    :style,
                    :author_year_separator,
                    :years_separator

      def initialize(bibpunct: ['(', ')', ';', 'a', ',', ','])
        @opening_bracket,
        @closing_bracket,
        @cites_separator,
        @style,
        @author_year_separator,
        @years_separator = bibpunct

      end

      def import(database)
        @database = database
      end

      def render(cite)
        macro_options = MACROS[cite.macro]
        output = []
        case macro_options[:type]
        when :textual
          cite.cites.each do |ct|
            authors = authors(macro_options[:authors], ct)
            year = year(ct)
            year = @opening_bracket + year(ct).to_s + @closing_bracket if macro_options[:bracketed]
            output << [authors, year].join(' ')
          end
          output = output.join(@cites_separator + ' ')
          # output = @opening_bracket + output + @closing_bracket if macro_options[:bracketed]
        when :parenthetical
          cite.cites.each do |ct|
            authors = authors(macro_options[:authors], ct)
            year = year(ct)
            year = year(ct).to_s
            output << [authors, year].join(@author_year_separator + ' ')
          end
          output = output.join(@cites_separator + ' ')
          output = @opening_bracket + output + @closing_bracket if macro_options[:bracketed]
        when :authors_only
          cite.cites.each do |ct|
            authors = authors(macro_options[:authors], ct)
            output << authors
          end
          output = output.join(@cites_separator + ' ')
          output = @opening_bracket + output + @closing_bracket if macro_options[:bracketed]
        when :years_only
          cite.cites.each do |ct|
            year = year(ct)
            output << year
          end
          output = output.join(@cites_separator + ' ')
          output = @opening_bracket + output + @closing_bracket if macro_options[:bracketed]
        else
        end

        output
      end

      private

      def year(cite)
        issued = @database.find{ |h| h['id'] == cite[:key] }['issued']['date-parts']
        return "" if issued.nil?
        issued.first.first # TODO
      end

      def authors(mode, cite)
        case mode
        when :full
          authors_full(cite)
        when :abbreviated
          authors_abbreviated(cite)
        else
          raise "ERROR: TODO"
        end
      end

      def authors_list(cite)
        authors = @database.find{ |h| h['id'] == cite[:key] }['author']
        return [] if authors.nil?
        authors.map{ |h| h['family'] }.compact
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
