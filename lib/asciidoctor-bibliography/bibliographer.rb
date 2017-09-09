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
      @occurring_keys.concat(citation.keys).uniq!
      citations.last.cites.each do |cite|
        cite.appearance_index = @occurring_keys.index(cite.key) + 1
      end
    end

    def sort
      if options['order'] == 'alphabetical'
        @occurring_keys = @occurring_keys.sort_by do |target|
          first_author_family_name(target)
        end
        citations.each do |citation|
          citation.cites.each do |cite|
            cite.appearance_index = @occurring_keys.index(cite.key)
          end
        end
      end
    end

    private

    def first_author_family_name(key)
      authors = database.find { |h| h['id'] == key }['author']
      return '' if authors.nil?
      authors.map { |h| h['family'] }.compact.first # TODO: is the first also alphabetically the first?
    end
  end
end
