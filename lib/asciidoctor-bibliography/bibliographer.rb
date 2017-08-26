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
        cite.reference_index = @occurring_keys.index(cite.key)
      end
    end

    def sort
      if options['order'] == 'alphabetical'
        @occurring_keys = @occurring_keys.sort_by do |target|
          first_author_family_name(target)
        end
        citations.each do |citation|
          citation.cites.each do |cite|
            cite.reference_index = @occurring_keys.index(cite.key)
          end
        end
      end
    end

    private

    def first_author_family_name(key)
      authors = database.find{ |h| h['id'] == key }['author']
      return "" if authors.nil?
      authors.map{ |h| h['family'] }.compact.first # TODO: is the first also alphabetically the first?
    end
  end
end
