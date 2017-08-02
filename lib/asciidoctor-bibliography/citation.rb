require 'asciidoctor/attribute_list'

module AsciidoctorBibliography
  class Citation
    REGEXP = /\\?(cite):(\S+)?\[(|.*?[^\\])\]/

    attr_reader :macro, :target, :attributes, :keys

    def initialize(macro, target, attributes)
      @macro = macro
      @target = target
      @attributes = ::Asciidoctor::AttributeList.new(attributes).parse
      # Bibliographic keys are all and only the positional attributes.
      @keys = @attributes.select { |hash_key, _| hash_key.is_a? Integer }.values
    end

    def render(formatter)
      @keys.map { |key| render_key(formatter, key) }.join(', ')
    end

    private

    def render_id(key)
      [key, 'bibliography'].compact.join('-')
    end

    def render_label(formatter, key)
      formatter.render(:citation, id: key)
    end

    def render_key(formatter, key)
      "xref:#{render_id(key)}[#{render_label(formatter, key)}]"
    end
  end
end

