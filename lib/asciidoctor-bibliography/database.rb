require_relative 'database_adapters/bibtex'

module AsciidoctorBibliography
  class Database < Array
    # This is an array of citeproc entries.

    def initialize(filename)
      self.concat self.load(filename)
    end

    def load(filename)
      if ['.bib', '.bibtex'].include? File.extname(filename)
        DatabaseAdapters::BibTeX.load(filename)
      else
        raise StandardError, "Unknown bibliographic database format."
      end
    end
  end
end

