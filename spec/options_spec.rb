require "asciidoctor"

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

  describe "#locale" do
    it "defaults to en-US" do
      expect(described_class.new.locale).to eq "en-US"
    end

    it "returns the provided option when set" do
      expect(described_class.new.merge("bibliography-locale" => "it-IT").locale).to eq "it-IT"
    end

    it "raises an error when provided option is invalid" do
      expect { described_class.new.merge("bibliography-locale" => "foo").locale }.
        to raise_exception AsciidoctorBibliography::Errors::Options::Invalid
    end
  end

  describe "#tex_style" do
    it "defaults to en-US" do
      expect(described_class.new.tex_style).to eq "authoryear"
    end

    it "returns the provided option when set" do
      expect(described_class.new.merge("bibliography-tex-style" => "numeric").tex_style).to eq "numeric"
    end

    it "raises an error when provided option is invalid" do
      expect { described_class.new.merge("bibliography-tex-style" => "foo").tex_style }.
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

  describe "#sort" do
    it "defaults to nil" do
      expect(described_class.new.sort).to be nil
    end

    it "parses and returns an empty array" do
      expect(described_class.new.merge("bibliography-sort" => "[]").sort).
        to eq([])
    end

    it "parses and returns a naked hash" do
      expect(described_class.new.merge("bibliography-sort" => "macro: author").sort).
        to eq([{ "macro" => "author" }])
    end

    it "parses and returns a hash" do
      expect(described_class.new.merge("bibliography-sort" => "{macro: author, sort: descending}").sort).
        to eq([{ "macro" => "author", "sort" => "descending" }])
    end

    it "parses and returns multiple hashes" do
      expect(described_class.new.merge("bibliography-sort" => "[{macro: author}, {variable: issued}]").sort).
        to eq([{ "macro" => "author" }, { "variable" => "issued" }])
    end

    it "raises an error when provided option is invalid (type)" do
      expect { described_class.new.merge("bibliography-sort" => "foo").sort }.
        to raise_exception AsciidoctorBibliography::Errors::Options::Invalid
    end

    it "raises an error when provided option is invalid (key)" do
      expect { described_class.new.merge("bibliography-sort" => "[{something: wrong}]").sort }.
        to raise_exception AsciidoctorBibliography::Errors::Options::Invalid
    end

    it "raises an error when provided option is invalid (syntax)" do
      expect { described_class.new.merge("bibliography-sort" => "foo: bar:").sort }.
        to raise_exception AsciidoctorBibliography::Errors::Options::Invalid
    end
  end

  describe ".new_from_reader" do
    let(:reader) do
      ::Asciidoctor::PreprocessorReader.new(::Asciidoctor::Document.new, <<~SOURCE.lines)
        = This is the document title
        :bibliography-database: foo
        :bibliography-locale: bar
        :bibliography-style: baz
        :bibliography-hyperlinks: quz
        :bibliography-order: zod
        :bibliography-tex-style: lep
        :bibliography-sort: kan
        :bibliography-bogus: pow
      SOURCE
    end

    subject { described_class.new_from_reader reader }

    it "extracts all bibliography options ignoring others" do
      expect(subject).to eq("bibliography-database" => "foo",
                            "bibliography-locale" => "bar",
                            "bibliography-style" => "baz",
                            "bibliography-hyperlinks" => "quz",
                            "bibliography-order" => "zod",
                            "bibliography-tex-style" => "lep",
                            "bibliography-sort" => "kan")
    end

    it "acts non-destructively on reader" do
      expect { subject }.to_not(change { reader.lines })
      expect { subject }.to_not(change { reader.cursor.lineno })
    end
  end
end
