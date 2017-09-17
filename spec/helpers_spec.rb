require "asciidoctor-bibliography/helpers"

describe AsciidoctorBibliography::Helpers do
  describe ".slice" do
    it "finds one or more existing keys" do
      expect(subject.slice({ foo: "bar", baz: "qux" }, :foo)).to eq(foo: "bar")
      expect(subject.slice({ foo: "bar", baz: "qux" }, :foo, :baz)).to eq(foo: "bar", baz: "qux")
    end

    it "returns nil for missing keys" do
      expect(subject.slice({}, :foo)).to eq(foo: nil)
      expect(subject.slice({ foo: "bar" }, :bar)).to eq(bar: nil)
      expect(subject.slice({ foo: "bar" }, :foo, :baz)).to eq(foo: "bar", baz: nil)
    end
  end

  describe ".join_nonempty" do
    it "ignores nils" do
      expect(subject.join_nonempty([nil], "-")).to eq("")
      expect(subject.join_nonempty(["foo", nil], "-")).to eq("foo")
      expect(subject.join_nonempty([nil, "bar"], "-")).to eq("bar")
      expect(subject.join_nonempty(["foo", nil, "bar"], "-")).to eq("foo-bar")
    end

    it "ignores empty strings" do
      expect(subject.join_nonempty([""], "-")).to eq("")
      expect(subject.join_nonempty(["foo", ""], "-")).to eq("foo")
      expect(subject.join_nonempty(["", "bar"], "-")).to eq("bar")
      expect(subject.join_nonempty(["foo", "", "bar"], "-")).to eq("foo-bar")
    end
  end

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

  describe ".to_sentence" do
    let(:new_options) do
      { words_connector:     "1",
        two_words_connector: "2",
        last_word_connector: "3" }
    end

    it "concatenates arbitrary arrays" do
      expect(subject.to_sentence([])).to eq("")
      expect(subject.to_sentence(["foo"])).to eq("foo")
      expect(subject.to_sentence(["foo", "bar"])).to eq("foo and bar")
      expect(subject.to_sentence(["foo", "bar", "baz"])).to eq("foo, bar, and baz")
      expect(subject.to_sentence(["foo", "bar", "baz", "qux"])).to eq("foo, bar, baz, and qux")
    end

    it "accepts custom separators" do
      expect(subject.to_sentence(["foo", "bar"], new_options)).to eq("foo2bar")
      expect(subject.to_sentence(["foo", "bar", "baz"], new_options)).to eq("foo1bar3baz")
    end
  end
end
