# coding: utf-8

require "asciidoctor-bibliography"
require "asciidoctor-bibliography/asciidoctor/bibliographer_preprocessor"

describe "an asciidoctor document with bibliography usage" do
  let(:document) do
    input = <<~'ASCIIDOC'
      = This is the document title
      :doctype: book
      :bibliography-database: ./spec/fixtures/database-issue84.bib
      :bibliography-style: university-of-york-mla
      == Section 1
      The Advanced Research Projects Agency Network (ARPANET),
      an early network connecting many major universities and
      research institutions in the USA,
      was first demonstrated publicly in October 1972
      cite:[roberts_arpanet_1986, page=3].
      It was initially funded by the United States
      Department of Defense during the cold war as a part of
      "the command and control assignment" of the ARPA program
      cite:[lukasik_why_2011, page=10].
      The ((ARPANET)) was designed to be "as distributed as possible,"
      because its routing algorithm was adapted from an article by Paul Baran,
      written at the time he was at the RAND Corporation researching
      on highly survivable communication networks "in the thermonuclear era"
      cite:[baran_distributed_1964, page=18].
      With the support of the US National Science Foundation, ARPANET gradually
      "evolved into a commercial, worldwide open network" -- the Internet
      cite:[dommering_internet:_2015, page=13].
      [bibliography]
      == Bibliography
      bibliography::[]
    ASCIIDOC
    document = ::Asciidoctor::Document.new(input)
    document.parse
    document
  end

  it "creates a valid internal bibliographer state" do
    expect(document.bibliographer.occurring_keys["default"]).
      to eq ["roberts_arpanet_1986",
             "lukasik_why_2011",
             "baran_distributed_1964",
             "dommering_internet:_2015"]
  end

  it "generates the correct mla bibliography" do
    expect(document.catalog[:refs]["_bibliography"].blocks[0].lines[0]).
      to include("Baran, Paul.")
    expect(document.catalog[:refs]["_bibliography"].blocks[1].lines[0]).
      to include("Dommering, E., et al.")
    expect(document.catalog[:refs]["_bibliography"].blocks[2].lines[0]).
      to include("Lukasik, Stephen.")
    expect(document.catalog[:refs]["_bibliography"].blocks[3].lines[0]).
      to include("Roberts, Larry.")
  end
end
