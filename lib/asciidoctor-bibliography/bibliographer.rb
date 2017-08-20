module AsciidoctorBibliography
  class Bibliographer
    attr_accessor :citations
    attr_accessor :indices
    attr_accessor :database
    attr_accessor :formatter
    attr_accessor :simple_formatter

    # NOTE: while database and formatter are singular, they're meant for future generalization.

    def initialize
      @citations = []
      @indices = []
      @database = nil
      @formatter = nil
      @simple_formatter = nil
    end
  end
end
