require 'asciidoctor/extensions'

require_relative 'asciidoctor/bibliographer_preprocessor'
require_relative 'bibliographer'

Asciidoctor::Extensions.register do
  preprocessor AsciidoctorBibliography::Asciidoctor::BibliographerPreprocessor
end

module Asciidoctor
  class Document
    # All our document-level permanence passes through this attribute accessor.
    def bibliographer
      @bibliographer ||= AsciidoctorBibliography::Bibliographer.new
    end
  end
end
