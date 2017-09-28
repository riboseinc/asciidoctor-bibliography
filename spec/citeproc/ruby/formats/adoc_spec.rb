# coding: utf-8

require "asciidoctor-bibliography"

TEST_BIBTEX_DATABASE = <<~BIBTEX.freeze
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

def init_bibliographer(options)
  bibliographer = AsciidoctorBibliography::Bibliographer.new

  bibliographer.options = AsciidoctorBibliography::Options.new.
    merge("bibliography-hyperlinks" => "false").merge(options)

  bibliographer.database = AsciidoctorBibliography::Database.new.
    concat(::BibTeX.parse(TEST_BIBTEX_DATABASE).to_citeproc)

  bibliographer
end

def formatted_bibliography(macro, options: {})
  bibliographer = init_bibliographer options

  bibliographer.
    add_citation AsciidoctorBibliography::Citation.new('cite', '', 'Gettier63')

  macro.lines.map do |line|
    if line =~ AsciidoctorBibliography::Index::REGEXP
      index = AsciidoctorBibliography::Index.new(*Regexp.last_match.captures)
      index.render bibliographer
    else
      line
    end
  end.flatten.map! { |ref| ref.gsub(/^{empty}anchor:.*?\[\]/, "") }
end

describe "custom :adoc citeproc format" do
  let(:options) { { "bibliography-style" => "ieee" } }

  it "adds space between first and second field" do
    expect(formatted_bibliography("bibliography::[]", options: options).first).
      to eq "[1] E. L. Gettier, “Is justified true belief knowledge?,” _analysis_, vol. 23, no. 6, pp. 121–123, 1963."
  end
end
