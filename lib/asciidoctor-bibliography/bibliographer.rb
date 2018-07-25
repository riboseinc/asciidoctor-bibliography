module AsciidoctorBibliography
  class Bibliographer
    attr_accessor :citations
    attr_accessor :indices
    attr_accessor :database
    attr_reader :occurring_keys
    attr_accessor :options

    def initialize
      @options = {}
      @citations = []
      @indices = []
      @database = nil
      @occurring_keys = {}
    end

    def add_citation(citation)
      citations << citation

      # NOTE: Since we're rendering the whole (possibly composite) citation as missing - even if
      # NOTE: a single key is nil - we add none of them to the occurring keys to be rendered in indices.
      return if citation.any_missing_id?(self)

      citation.citation_items.group_by(&:target).each do |target, citation_items|
        @occurring_keys[target] ||= []
        @occurring_keys[target].concat(citation_items.map(&:key)).uniq!
      end
    end

    def appearance_index_of(target, id)
      @occurring_keys[target].index(id) + 1
    end
  end
end
