# coding: utf-8

require "asciidoctor-bibliography"
require_relative "../../../citation_helper"

TEST_ADOC_SPEC_DATABASE = <<~BIBTEX.freeze
  @article{Gettier63,
    title={Is justified true belief knowledge?},
    author={Gettier, Edmund L},
    journal={analysis},
    volume={23},
    number={6},
    pages={121--123},
    year={1963},
    publisher={JSTOR}
  }
BIBTEX

def formatted_bibliography(macro, options: {})
  bibliographer = init_bibliographer bibtex_db: TEST_ADOC_SPEC_DATABASE,
                                     options: options

  bibliographer.
    add_citation AsciidoctorBibliography::Citation.new("cite", "", "Gettier63")

  entries = macro.lines.map do |line|
    return line unless line =~ AsciidoctorBibliography::Index::REGEXP
    index = AsciidoctorBibliography::Index.new(*Regexp.last_match.captures)
    index.render bibliographer
  end

  entries.flatten.map! { |ref| ref.gsub(/^{empty}anchor:.*?\[\]/, "") }
end

describe "custom :adoc citeproc format" do
  let(:options) { { "bibliography-style" => "ieee" } }

  it "adds space between first and second field" do
    expect(formatted_bibliography("bibliography::[]", options: options).first).
      to eq "[1] E. L. Gettier, “Is justified true belief knowledge?,” _analysis_, vol. 23, no. 6, pp. 121–123, 1963."
  end
end
