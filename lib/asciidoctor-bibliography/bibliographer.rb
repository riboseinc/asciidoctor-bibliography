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
      @occurring_keys = []
    end

    def add_citation(citation)
      citations << citation
      @occurring_keys.concat(citation.citation_items.map(&:key)).uniq!
    end

    def appearance_index_of(id)
      @occurring_keys.index(id) + 1
    end
  end
end
