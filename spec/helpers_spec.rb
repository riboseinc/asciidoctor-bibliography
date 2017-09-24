require "asciidoctor-bibliography/helpers"

describe AsciidoctorBibliography::Helpers do
  describe ".html_to_asciidoc" do
    it "converts italic" do
      expect(subject.html_to_asciidoc("This is <i>italic</i>.")).to eq("This is _italic_.")
    end

    it "converts bold" do
      expect(subject.html_to_asciidoc("This is <b>bold</b>.")).to eq("This is *bold*.")
    end

    it "drops spans" do
      expect(subject.html_to_asciidoc('This is a <span attribute="value">span</span>.')).
        to eq("This is a span.")
    end

    it "drops curly brackets" do
      expect(subject.html_to_asciidoc("This is {bracketed}.")).
        to eq("This is bracketed.")
    end
  end
end
