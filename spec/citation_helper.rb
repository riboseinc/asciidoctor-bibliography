# coding: utf-8

require "asciidoctor-bibliography"

TEST_BIBTEX_DATABASE = <<~BIBTEX.freeze
  @article{Erdos65,
    title = {Some very hard sums},
    journal={Difficult Maths Today},
    author={Paul Erdős and Arend Heyting and Luitzen Egbertus Brouwer},
    year={1965},
    pages={30}
  }

  @article{Einstein35,
    title={Can quantum-mechanical description of physical reality be considered complete?},
    author={Einstein, Albert and Podolsky, Boris and Rosen, Nathan},
    journal={Physical review},
    volume={47},
    number={10},
    pages={777},
    year={1935},
    publisher={APS}
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

def formatted_citation(macro, options: {})
  bibliographer = init_bibliographer options

  macro.gsub(AsciidoctorBibliography::Citation::REGEXP) do
    citation = AsciidoctorBibliography::Citation.new(*Regexp.last_match.captures)
    bibliographer.add_citation(citation)
    citation.render bibliographer
  end.gsub(/^{empty}/, "")
end
