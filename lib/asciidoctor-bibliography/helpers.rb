module AsciidoctorBibliography
  module Helpers
    def self.html_to_asciidoc(string)
      string.
        gsub(%r{<\/?i>}, "_").
        gsub(%r{<\/?b>}, "*").
        gsub(%r{<\/?span.*?>}, "").
        gsub(/\{|\}/, "")
      # TODO: bracket dropping is inappropriate here.
    end
  end
end
