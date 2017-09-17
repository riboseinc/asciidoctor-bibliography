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

    def sort
      return unless options["order"] == "alphabetical"
      @occurring_keys = @occurring_keys.sort_by do |target|
        first_author_family_name(target)
      end
    end

    private

    def first_author_family_name(key)
      authors = database.detect { |h| h["id"] == key }["author"]
      return "" if authors.nil?
      authors.map { |h| h["family"] }.compact.first # TODO: is the first also alphabetically the first?
    end
  end
end
