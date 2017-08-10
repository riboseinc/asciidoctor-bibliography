require 'asciidoctor/attribute_list'

module AsciidoctorBibliography
  class Citation
    REGEXP = /\\?(cite):(?:(\S*?)?\[(|.*?[^\\])\])(?:\+(\S*?)?\[(|.*?[^\\])\])*/

    attr_reader :macro, :cites

    def initialize(macro, *targets_and_attributes_list)
      @macro = macro
      @cites = []
      targets_and_attributes_list.compact.each_slice(2).each do |target, attributes|
        positional_attributes, named_attributes = # true, false
          ::Asciidoctor::AttributeList.new(attributes).parse
            .group_by { |hash_key, _| hash_key.is_a? Integer }
            .values.map { |a| Hash[a] }
        positional_attributes = positional_attributes.values
        @cites << {
          target: target,
          key: positional_attributes.first,
          attributes: {
            positional: positional_attributes,
            named: named_attributes
          }
        }
      end
    end

    def render(formatter)
      keys.map { |key| render_xref(formatter, key) }.join(', ')
    end

    def keys
      @cites.map { |h| h[:key] }
    end

    private

    def render_id(key)
      [key, 'bibliography'].compact.join('-')
    end

    def render_label(formatter, key)
      formatter.render(:citation, id: key)
    end

    def render_xref(formatter, key)
      "xref:#{render_id(key)}[#{render_label(formatter, key)}]"
    end
  end
end

