require 'asciidoctor/attribute_list'

module AsciidoctorBibliography
  class Citation
    attr_reader :macro, :target, :attributes

    def initialize(macro, target, attributes)
      @macro = macro
      @target = target
      @attributes = ::Asciidoctor::AttributeList.new(attributes).parse
    end

    def render_id
      [self.target, 'bibliography'].compact.join('-')
    end

    def render_label(formatter)
      formatter.render(:citation, id: self.target)
    end

    def render(formatter)
      "xref:#{render_id}[#{render_label(formatter)}]"
    end
  end
end

