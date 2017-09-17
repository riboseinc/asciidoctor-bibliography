require "asciidoctor-bibliography/helpers"

describe AsciidoctorBibliography::Options do
  describe "#database" do
    it "has no default" do
      expect { described_class.new.database }.
        to raise_exception AsciidoctorBibliography::Errors::Options::Missing
    end

    it "returns the provided database name" do
      expect(described_class.new.merge("bibliography-database" => "foobar").database).to eq("foobar")
    end
  end

  describe "#hyperlinks?" do
    it "defaults to true" do
      expect(described_class.new.hyperlinks?).to be true
    end

    it "returns true when provided option is true" do
      expect(described_class.new.merge("bibliography-hyperlinks" => "false").hyperlinks?).to be false
    end

    it "returns true when provided option is true" do
      expect(described_class.new.merge("bibliography-hyperlinks" => "true").hyperlinks?).to be true
    end

    it "raises an error when provided option is invalid" do
      expect { described_class.new.merge("bibliography-hyperlinks" => "foo").hyperlinks? }.
        to raise_exception AsciidoctorBibliography::Errors::Options::Invalid
    end
  end

  describe "#style" do
    it "defaults to apa" do
      expect(described_class.new.style).to eq "apa"
    end

    it "returns the provided style name" do
      expect(described_class.new.merge("bibliography-style" => "foobar").style).to eq("foobar")
    end
  end
end
