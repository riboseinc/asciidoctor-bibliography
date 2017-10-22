require "asciidoctor"

def setup_tmpdir(method_name = :tmpdir)
  let(method_name) { File.join Dir.tmpdir, "asciidoctor-bibliography_tests" }

  around(:each) do |example|
    FileUtils.rm_rf method(method_name).call
    FileUtils.mkdir_p method(method_name).call
    example.run
    FileUtils.rm_rf method(method_name).call
  end
end

def setup_main_document(_path, content)
  input_path = File.join(tmpdir, "main.adoc")
  output_path = File.join(tmpdir, "main.html")
  File.open(input_path, "w") { |file| file.write content }
  [input_path, output_path]
end

def setup_file(_path, name, content)
  File.open(File.join(tmpdir, name), "w") { |file| file.write content }
end

def setup_bibliography(content)
  let(:bibliography_path) do
    File.join(tmpdir, "bibliography.bibtex")
  end

  before do
    File.open(bibliography_path, "w") { |file| file.write content }
  end
end

describe "asciidoctor integration" do
  setup_tmpdir

  setup_bibliography <<~BIBTEX
    @article{Foo00,
      author = {Foo Bar},
      title =	{Title},
      publisher = {Publisher},
      year = {2000}
    }
  BIBTEX

  describe "testing procedure" do
    it "works in the trivial case" do
      input_path, output_path = setup_main_document tmpdir, <<~'ADOC'
        Hello World.
      ADOC

      expect { `asciidoctor #{input_path}` }.to_not raise_exception
      expect(File.read(output_path)).to match <<~'BODY'
        <div id="content">
        <div class="paragraph">
        <p>Hello World.</p>
        </div>
        </div>
      BODY
    end
  end

  describe "single file usage" do
    it "works with a single file, a citation and the bibliography" do
      input_path, output_path = setup_main_document tmpdir, <<~ADOC
        :bibliography-database: #{bibliography_path}

        Hello World. cite:[Foo00]

        bibliography::[]
      ADOC

      expect { `asciidoctor -r asciidoctor-bibliography #{input_path} --trace` }.to_not raise_exception
      expect(File.read(output_path)).to include <<~'BODY'
        <div id="content">
        <div class="paragraph">
        <p>Hello World. (<a href="#bibliography-default-Foo00">Bar, 2000</a>)</p>
        </div>
        <div class="paragraph">
        <p><a id="bibliography-default-Foo00"></a>Bar, F. (2000). Title.</p>
        </div>
        </div>
      BODY
    end
  end

  describe "nested files usage" do
    it "works with a single file, a citation and the bibliography" do
      setup_file tmpdir, "nested.adoc", <<~ADOC
        This is content from a nested file. cite:[Foo00]

        bibliography::[]
      ADOC

      input_path, output_path = setup_main_document tmpdir, <<~ADOC
        :bibliography-database: #{bibliography_path}

        Hello World. cite:[Foo00]

        include::nested.adoc[]
      ADOC

      expect { `asciidoctor -r asciidoctor-bibliography #{input_path} --trace` }.to_not raise_exception
      expect(File.read(output_path)).to include <<~'BODY'
        <div id="content">
        <div class="paragraph">
        <p>Hello World. (<a href="#bibliography-default-Foo00">Bar, 2000</a>)</p>
        </div>
        <div class="paragraph">
        <p>This is content from a nested file. (<a href="#bibliography-default-Foo00">Bar, 2000</a>)</p>
        </div>
        <div class="paragraph">
        <p><a id="bibliography-default-Foo00"></a>Bar, F. (2000). Title.</p>
        </div>
        </div>
      BODY
    end
  end
end
