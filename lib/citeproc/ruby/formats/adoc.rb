require "citeproc/ruby/format"

module CiteProc
  module Ruby
    module Formats
      class Adoc < Format
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
          output.replace "^#{output}^" if options[:"vertical-align"] == "sup"
          output.replace "~#{output}~" if options[:"vertical-align"] == "sub"
        end

        def apply_suffix
          options[:suffix] += " " if aligned_first_field?
          super
        end

        private

        def aligned_first_field?
          return node.root.bibliography.layout.children.first == node if aligned_first_accessible?
          false
        end

        def aligned_first_accessible?
          !(node.root.is_a? CSL::Locale) &&
            node.root.respond_to?(:bibliography) &&
            node.root.bibliography["second-field-align"]
        end
      end
    end
  end
end
