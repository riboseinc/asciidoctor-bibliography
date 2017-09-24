require "citeproc/ruby/format"

module CiteProc
  module Ruby
    module Formats
      class Adoc < Format
        # TODO
        # def bibliography(bibliography)
        # end

        def apply_font_style
          output.replace "_#{output}_" if options[:'font-style'] == "italic"
        end

        # TODO
        # def apply_font_variant
        #   output.replace "*#{output}*" if options[:'font-variant'] == 'small-caps'
        # end

        def apply_font_weight
          output.replace "*#{output}*" if options[:'font-weight'] == "bold"
        end

        # TODO
        # def apply_text_decoration
        #   output.replace "*#{output}*" if options[:'text-decoration'] == 'underline'
        # end

        def apply_vertical_align
          output.replace "^#{output}^" if options[:vertical_align] == "sup"
          output.replace "~#{output}~" if options[:vertical_align] == "sub"
        end
      end
    end
  end
end
