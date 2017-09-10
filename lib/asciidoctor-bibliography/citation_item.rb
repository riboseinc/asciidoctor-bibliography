require 'asciidoctor/attribute_list'

module AsciidoctorBibliography
  class CitationItem
    attr_accessor :key, :target, :positional_attributes, :named_attributes, :locators

    def initialize
      yield self if block_given?
    end

    def locators
      Helpers
        .slice(named_attributes || {}, *CiteProc::CitationItem.labels.map(&:to_s))
        .reject { |_, value| value.nil? || value.empty? } # equivalent to Hash#compact
    end

    def parse_attribute_list(string)
      parsed_attributes =
        ::Asciidoctor::AttributeList.new(string).parse
                                    .group_by { |hash_key, _| hash_key.is_a? Integer }
                                    .values.map { |a| Hash[a] }
      self.positional_attributes = parsed_attributes.first.values
      self.named_attributes = parsed_attributes.last
      self.key = positional_attributes.shift
    end
  end
end
