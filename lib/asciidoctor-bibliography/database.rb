require_relative 'databases/bibtex'
require_relative 'exceptions'

module AsciidoctorBibliography
  # This is an array of citeproc entries.
  class Database < Array
    def initialize(*filenames)
      filenames.each do |filename|
        append filename
      end
    end

    def append(filename)
      concat Database.load(filename)
    end

    def self.load(filename)
      case File.extname(filename)
      when *Databases::BibTeX::EXTENSIONS
        Databases::BibTeX.load(filename)
      else
        raise Exceptions::DatabaseFormatNotSupported,
              'Bibliographic database format not supported.'
      end
    end
  end
end
