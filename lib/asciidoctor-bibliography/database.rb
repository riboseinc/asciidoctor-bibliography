require_relative "databases/bibtex"
require_relative "errors"

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

    def find_entry_by_id(id)
      result = detect { |entry| entry["id"] == id }
      if result.nil?
        message = "No entry with id '#{id}' was found in the bibliographic database."
        raise Errors::Database::IdNotFound, message
      end
      result
    end

    def self.load(filename)
      filepath = File.expand_path filename
      raise Errors::Database::FileNotFound, filepath unless File.exist?(filepath)

      fileext = File.extname filepath
      case fileext
      when *Databases::BibTeX::EXTENSIONS
        Databases::BibTeX.load filepath
      else
        raise Errors::Database::UnsupportedFormat, fileext
      end
    end
  end
end
