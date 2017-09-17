require "asciidoctor-bibliography/helpers"

describe AsciidoctorBibliography::CitationItem do
  describe ".new" do
    it "can be mutely initialized" do
      expect { described_class.new }.to_not raise_exception
    end

    it "can be initialized with a block operating on itself" do
      itself = nil
      expect(described_class.new { |ci| itself = ci }).to be(itself)
    end
  end

  describe "#parse_attribute_list" do
    subject { described_class.new }

    before do
      subject.parse_attribute_list "foo, lol=bar, baz, qux, zod=13"
    end

    it "treats the first positional attribute as the id" do
      expect(subject.key).to eq "foo"
    end

    it "extracts the positional attributes in order, except the first one" do
      expect(subject.positional_attributes).to eq ["baz", "qux"]
    end

    it "extracts all named attributes" do
      expect(subject.named_attributes).to eq("lol" => "bar", "zod" => "13")
    end
  end

  describe "#locators" do
    subject { described_class.new }

    it "returns no locators if none are present" do
      subject.parse_attribute_list "foo, lol=bar, baz, qux, zod=13"
      expect(subject.locators).to eq ({})
    end

    it "recognizes all CSL locators" do
      locators = %w[book chapter column figure folio issue line note opus
                    page paragraph part section sub-verbo verse volume]
      locators_hash = locators.map { |l| [l, rand(10).to_s] }.to_h
      locators_string = locators_hash.to_a.map { |a| a.join "=" }.join(", ")

      subject.parse_attribute_list "foo, #{locators_string}"
      expect(subject.locators).to eq locators_hash
    end
  end
end
