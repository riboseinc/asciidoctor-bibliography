# coding: utf-8

require "asciidoctor-bibliography"

describe "rendering citations styles containing square brackets" do
  let(:parsed_document) do
    Asciidoctor::Document.new(<<~ADOC_INPUT).tap(&:parse)
      = Sample document
      :bibliography-database: spec/fixtures/database.bib
      :bibliography-hyperlinks: true
      :bibliography-style: ieee
      ...

      This paragraph contains a citation: cite:[Lane12a].
      It also contains [.my-class]#some# inline styling.
    ADOC_INPUT
  end

  it "does not confuse rendered brackets with macro brackets in the paragraph" do
    # I.e. we're trying to avoid results like
    # ```
    # <p>This paragraph contains a citation: <a href="#bibliography-default-Lane12a"><span class="1&rsqb;</a>.
    # It also contains [.my-class">some</span> inline styling.</p>
    # ```
    expect(parsed_document.render).to eq(<<~HTML_OUTPUT.strip)
      <div class="paragraph">
      <p>This paragraph contains a citation: <a href="#bibliography-default-Lane12a">&lsqb;1&rsqb;</a>.
      It also contains <span class="my-class">some</span> inline styling.</p>
      </div>
    HTML_OUTPUT
  end
end
