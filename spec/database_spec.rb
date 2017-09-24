describe AsciidoctorBibliography::Database do
  describe ".new" do
    it "is by default an empty array" do
      expect(described_class.new).to eq([])
    end

    it "can be initialized with a single database" do
      expect(described_class.new("spec/fixtures/database.bib")).to_not eq([])
    end

    it "can be initialized with a list of databases" do
      expect(described_class.new("spec/fixtures/database.bib", "spec/fixtures/database.bibtex")).to_not eq([])
    end
  end

  describe "#append" do
    let(:db) { described_class.new }

    it "can load and concatenate databases after initialization" do
      expect(db.length).to eq(0)
      expect { db.append("spec/fixtures/database.bib") }.to(change { db.length })
      expect { db.append("spec/fixtures/database.bibtex") }.to(change { db.length })
    end
  end

  describe ".load" do
    it "raises error if given non existing file" do
      expect { described_class.load "spec/fixtures/database.xxx" }.
        to raise_exception AsciidoctorBibliography::Errors::Database::FileNotFound
    end

    it "raises error if given unknown format" do
      expect { described_class.load "spec/fixtures/database.unk" }.
        to raise_exception AsciidoctorBibliography::Errors::Database::UnsupportedFormat
    end

    it "recognizes Bib(La)Tex databases" do
      expect { described_class.load "spec/fixtures/database.bib" }.to_not raise_exception
      expect { described_class.load "spec/fixtures/database.bibtex" }.to_not raise_exception
    end
  end
end
