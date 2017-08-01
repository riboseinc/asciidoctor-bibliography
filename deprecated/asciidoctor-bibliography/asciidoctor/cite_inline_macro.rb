require 'asciidoctor'
require 'asciidoctor/extensions'

require 'securerandom'

module AsciidoctorBibliography
  module Asciidoctor

    class CiteInlineMacro < ::Asciidoctor::Extensions::InlineMacroProcessor
      use_dsl

      named :cite
      # name_positional_attributes 'volnum'

      def process parent, target, attrs
        puts self

        citation = AsciidoctorBibliography::Citation.new parent, target, attrs, SecureRandom.uuid
        parent.document.bibliographer.citations << citation

        # text = target # TODO: typeset
        # target = "#bibliography-#{target}"
        # parent.document.register :links, target
        # (create_anchor parent, text, type: :link, target: target).render

        citation.placeholder
      end
    end
  end
end
