module AsciidoctorBibliography
  class Bibliographer
    attr_accessor :citations
    attr_accessor :indices
    attr_accessor :database
    attr_accessor :index_formatter
    attr_accessor :citation_formatter
    attr_reader :occurring_keys
    attr_accessor :options

    # NOTE: while database and formatter are singular, they're meant for future generalization.

    def initialize
      @options = {}
      @citations = []
      @indices = []
      @database = nil
      @index_formatter = nil
      @citation_formatter = nil
      @occurring_keys = []
    end

    def add_citation(citation)
      citations << citation
      @occurring_keys.concat(citation.keys).uniq!
      citations.last.cites.each do |cite|
        cite.occurrence_index = @occurring_keys.index(cite.key)
      end
    end
  end
end
