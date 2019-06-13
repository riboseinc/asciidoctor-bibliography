# coding: utf-8

require "asciidoctor-bibliography"

describe "a typical usage of nocite" do
  let(:document) do
    input = <<~'ASCIIDOC'
      :bibliography-database: ./spec/fixtures/database.bib
      :bibliography-style: apa

      == Hidden citations
      Nothing here: nocite:[Lane12a].
      Nothing here: nocite:[Erdos65]+special[Einstein35].

      == Default bibliography
      bibliography::[]

      == Special bibliography
      bibliography::special[]
    ASCIIDOC
    document = ::Asciidoctor::Document.new(input)
    document.parse
    document
  end

  it "hides citations and show references" do
    expect(document.convert).to eq <<~HTML.rstrip
      <div class="sect1">
      <h2 id="_hidden_citations">Hidden citations</h2>
      <div class="sectionbody">
      <div class="paragraph">
      <p>Nothing here: .
      Nothing here: .</p>
      </div>
      </div>
      </div>
      <div class="sect1">
      <h2 id="_default_bibliography">Default bibliography</h2>
      <div class="sectionbody">
      <div class="paragraph">
      <p><a id="bibliography-default-Erdos65"></a>Erdős, P., Heyting, A., &amp; Brouwer, L. E. (1965). Some very hard sums. <em>Difficult Maths Today</em>, 30.</p>
      </div>
      <div class="paragraph">
      <p><a id="bibliography-default-Lane12a"></a>Lane, P. (2000). <em>Book title</em>. Publisher.</p>
      </div>
      </div>
      </div>
      <div class="sect1">
      <h2 id="_special_bibliography">Special bibliography</h2>
      <div class="sectionbody">
      <div class="paragraph">
      <p><a id="bibliography-special-Einstein35"></a>Einstein, A., Podolsky, B., &amp; Rosen, N. (1935). Can quantum-mechanical description of physical reality be considered complete? <em>Physical Review</em>, <em>47</em>(10), 777.</p>
      </div>
      </div>
      </div>
    HTML
  end
end
