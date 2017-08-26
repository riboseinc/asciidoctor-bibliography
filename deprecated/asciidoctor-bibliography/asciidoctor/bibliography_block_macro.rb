require 'bibtex'

require 'asciidoctor'
require 'asciidoctor/extensions'
require 'asciidoctor/reader'
require 'asciidoctor/parser'
# require 'bibliography/filters'
# require 'latex/decode/base'
# require 'latex/decode/maths'
# require 'latex/decode/accents'
# require 'latex/decode/diacritics'
# require 'latex/decode/punctuation'
# require 'latex/decode/symbols'
# require 'latex/decode/greek'
# require_relative 'styles'
# require_relative 'filehandlers'

module AsciidoctorBibliography
  module Asciidoctor
    class BibliographyBlockMacro < ::Asciidoctor::Extensions::BlockMacroProcessor
      use_dsl
      named :bibliography
      # positional_attributes :style

      def process parent, target, attrs
        puts self

        # List of targets to render
        keys = parent.document.bibliographer.occurrences.map { |o| o[:target] }.uniq


        # NOTE: bibliography-file and bibliography-reference-style set by this macro
        #   shall be overridable by document attributes and commandline arguments.
        #   So we respect the convention here.

        # if target and not parent.document.attr? 'bibliography-file'
        #   parent.document.set_attribute 'bibliography-file', target
        # end

        if parent.document.attr? 'bibliography-database'
          parent.document.bibliographer.load_database parent.document.attributes['bibliography-database']
        end

        # if attrs.key? :style and not parent.document.attr? 'bibliography-reference-style'
        #   parent.document.set_attribute 'bibliography-reference-style', attrs[:style]
        # end

        # index = AsciidoctorBibliography::Index.new parent, target, attrs, SecureRandom.uuid
        # parent.document.bibliographer.indices << index

        # html = index.placeholder
        # attrs = {}

        # create_pass_block parent, html, attrs#, subs: nil

        # parent.document.register :links, target
        # create_anchor parent, text, type: :link, target: target

        # byebug

        # keys.each do |key|
        #   create_paragraph parent, key, {}
        # end

        # index_block = create_block parent, a
        create_paragraph index_block, keys.first, {}

        # Asciidoctor::Block.new(parent, :paragraph, :source => '_This_ is a <test>')

        # TODO: unordered list
      end
    end

  end
end
