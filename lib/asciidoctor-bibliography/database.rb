require_relative 'databases/bibtex'

module AsciidoctorBibliography
  class Database < Array
    # This is an array of citeproc entries.

    def initialize(filename)
      concat load(filename)
    end

    def load(filename)
      case File.extname(filename)
      when *Databases::BibTeX::EXTENSIONS
        Databases::BibTeX.load(filename)
      else
        raise StandardError, 'Unknown bibliographic database format.'
      end
    end
  end
end
