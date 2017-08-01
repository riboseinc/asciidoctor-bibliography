module AsciidoctorBibliography
  module Helpers
    def self.slice(hash, *array_of_keys)
      Hash[[array_of_keys, hash.values_at(*array_of_keys)].transpose]
    end

    def self.html_to_asciidoc(string)
      string
        .gsub(/<\/?i>/, '_')
        .gsub(/<\/?b>/, '*')
        .gsub(/<\/?span.*?>/, '')
        .gsub(/\{|\}/, '')
    end
  end
end
