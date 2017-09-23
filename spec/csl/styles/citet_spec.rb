# coding: utf-8

require "asciidoctor-bibliography"

def formatted_citation(macro, style: "ieee")
  bibliographer = AsciidoctorBibliography::Bibliographer.new
  bibliographer.options = AsciidoctorBibliography::Options.new.
    merge("bibliography-hyperlinks" => "false")
  bibliographer.database = AsciidoctorBibliography::Database.new.concat ::BibTeX.parse(<<-BIBTEX).to_citeproc
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

  macro.gsub(AsciidoctorBibliography::Citation::REGEXP) do
    citation = AsciidoctorBibliography::Citation.new(*Regexp.last_match.captures)
    bibliographer.add_citation(citation)
    citation.render bibliographer
  end.gsub(/^{empty}/, "")
end

describe "citet macro" do
  it "formats a single citation" do
    expect(formatted_citation("citet:[Erdos65]")).
      to eq "Erdős et al. (1965)"
  end

  it "formats a grouped citation" do
    expect(formatted_citation("citet:[Erdos65]+[Einstein35]")).
      to eq "Erdős et al. (1965); Einstein et al. (1935)"
  end

  it "formats a single citation with a prefix" do
    expect(formatted_citation("citet:[Erdos65, prefix=see]")).
      to eq "Erdős et al. (see 1965)"
  end

  it "formats a single citation with a suffix" do
    expect(formatted_citation("citet:[Erdos65, suffix=new edition]")).
      to eq "Erdős et al. (1965, new edition)"
  end

  it "formats a single citation with both a prefix and a suffix" do
    expect(formatted_citation("citet:[Erdos65, prefix=see, suffix=new edition]")).
      to eq "Erdős et al. (see 1965, new edition)"
  end

  it "formats a single citation with a standard locator" do
    expect(formatted_citation("citet:[Erdos65, page=41-43]")).
      to eq "Erdős et al. (1965, pp. 41-43)"
  end

  it "formats a single citation with a custom locator" do
    expect(formatted_citation("citet:[Erdos65, locator=somewhere]")).
      to eq "Erdős et al. (1965, somewhere)"
  end
end


describe "citet* macro" do
  it "formats a single citation" do
    expect(formatted_citation("citet*:[Erdos65]")).
      to eq "Erdős, Heyting, and Brouwer (1965)"
  end

  it "formats a grouped citation" do
    expect(formatted_citation("citet*:[Erdos65]+[Einstein35]")).
      to eq "Erdős, Heyting, and Brouwer (1965); Einstein, Podolsky, and Rosen (1935)"
  end

  it "formats a single citation with a prefix" do
    expect(formatted_citation("citet*:[Erdos65, prefix=see]")).
      to eq "Erdős, Heyting, and Brouwer (see 1965)"
  end

  it "formats a single citation with a suffix" do
    expect(formatted_citation("citet*:[Erdos65, suffix=new edition]")).
      to eq "Erdős, Heyting, and Brouwer (1965, new edition)"
  end

  it "formats a single citation with both a prefix and a suffix" do
    expect(formatted_citation("citet*:[Erdos65, prefix=see, suffix=new edition]")).
      to eq "Erdős, Heyting, and Brouwer (see 1965, new edition)"
  end

  it "formats a single citation with a standard locator" do
    expect(formatted_citation("citet*:[Erdos65, page=41-43]")).
      to eq "Erdős, Heyting, and Brouwer (1965, pp. 41-43)"
  end

  it "formats a single citation with a custom locator" do
    expect(formatted_citation("citet*:[Erdos65, locator=somewhere]")).
      to eq "Erdős, Heyting, and Brouwer (1965, somewhere)"
  end
end

describe "citep macro" do
  it "formats a single citation" do
    expect(formatted_citation("citep:[Erdos65]")).
      to eq "(Erdős et al., 1965)"
  end

  it "formats a grouped citation" do
    expect(formatted_citation("citep:[Erdos65]+[Einstein35]")).
      to eq "(Erdős et al., 1965; Einstein et al., 1935)"
  end

  it "formats a single citation with a prefix" do
    expect(formatted_citation("citep:[Erdos65, prefix=see]")).
      to eq "(see Erdős et al., 1965)"
  end

  it "formats a single citation with a suffix" do
    expect(formatted_citation("citep:[Erdos65, suffix=new edition]")).
      to eq "(Erdős et al., 1965, new edition)"
  end

  it "formats a single citation with both a prefix and a suffix" do
    expect(formatted_citation("citep:[Erdos65, prefix=see, suffix=new edition]")).
      to eq "(see Erdős et al., 1965, new edition)"
  end

  it "formats a single citation with a standard locator" do
    expect(formatted_citation("citep:[Erdos65, page=41-43]")).
      to eq "(Erdős et al., 1965, pp. 41-43)"
  end

  it "formats a single citation with a custom locator" do
    expect(formatted_citation("citep:[Erdos65, locator=somewhere]")).
      to eq "(Erdős et al., 1965, somewhere)"
  end
end

describe "citep* macro" do
  it "formats a single citation" do
    expect(formatted_citation("citep*:[Erdos65]")).
      to eq "(Erdős, Heyting, and Brouwer, 1965)"
  end

  it "formats a grouped citation" do
    expect(formatted_citation("citep*:[Erdos65]+[Einstein35]")).
      to eq "(Erdős, Heyting, and Brouwer, 1965; Einstein, Podolsky, and Rosen, 1935)"
  end

  it "formats a single citation with a prefix" do
    expect(formatted_citation("citep*:[Erdos65, prefix=see]")).
      to eq "(see Erdős, Heyting, and Brouwer, 1965)"
  end

  it "formats a single citation with a suffix" do
    expect(formatted_citation("citep*:[Erdos65, suffix=new edition]")).
      to eq "(Erdős, Heyting, and Brouwer, 1965, new edition)"
  end

  it "formats a single citation with both a prefix and a suffix" do
    expect(formatted_citation("citep*:[Erdos65, prefix=see, suffix=new edition]")).
      to eq "(see Erdős, Heyting, and Brouwer, 1965, new edition)"
  end

  it "formats a single citation with a standard locator" do
    expect(formatted_citation("citep*:[Erdos65, page=41-43]")).
      to eq "(Erdős, Heyting, and Brouwer, 1965, pp. 41-43)"
  end

  it "formats a single citation with a custom locator" do
    expect(formatted_citation("citep*:[Erdos65, locator=somewhere]")).
      to eq "(Erdős, Heyting, and Brouwer, 1965, somewhere)"
  end
end














describe "citealt macro" do
  it "formats a single citation" do
    expect(formatted_citation("citealt:[Erdos65]")).
      to eq "Erdős et al. 1965"
  end

  it "formats a grouped citation" do
    expect(formatted_citation("citealt:[Erdos65]+[Einstein35]")).
      to eq "Erdős et al. 1965; Einstein et al. 1935"
  end

  it "formats a single citation with a prefix" do
    expect(formatted_citation("citealt:[Erdos65, prefix=see]")).
      to eq "Erdős et al. see 1965"
  end

  it "formats a single citation with a suffix" do
    expect(formatted_citation("citealt:[Erdos65, suffix=new edition]")).
      to eq "Erdős et al. 1965, new edition"
  end

  it "formats a single citation with both a prefix and a suffix" do
    expect(formatted_citation("citealt:[Erdos65, prefix=see, suffix=new edition]")).
      to eq "Erdős et al. see 1965, new edition"
  end

  it "formats a single citation with a standard locator" do
    expect(formatted_citation("citealt:[Erdos65, page=41-43]")).
      to eq "Erdős et al. 1965, pp. 41-43"
  end

  it "formats a single citation with a custom locator" do
    expect(formatted_citation("citealt:[Erdos65, locator=somewhere]")).
      to eq "Erdős et al. 1965, somewhere"
  end
end


describe "citealt* macro" do
  it "formats a single citation" do
    expect(formatted_citation("citealt*:[Erdos65]")).
      to eq "Erdős, Heyting, and Brouwer 1965"
  end

  it "formats a grouped citation" do
    expect(formatted_citation("citealt*:[Erdos65]+[Einstein35]")).
      to eq "Erdős, Heyting, and Brouwer 1965; Einstein, Podolsky, and Rosen 1935"
  end

  it "formats a single citation with a prefix" do
    expect(formatted_citation("citealt*:[Erdos65, prefix=see]")).
      to eq "Erdős, Heyting, and Brouwer see 1965"
  end

  it "formats a single citation with a suffix" do
    expect(formatted_citation("citealt*:[Erdos65, suffix=new edition]")).
      to eq "Erdős, Heyting, and Brouwer 1965, new edition"
  end

  it "formats a single citation with both a prefix and a suffix" do
    expect(formatted_citation("citealt*:[Erdos65, prefix=see, suffix=new edition]")).
      to eq "Erdős, Heyting, and Brouwer see 1965, new edition"
  end

  it "formats a single citation with a standard locator" do
    expect(formatted_citation("citealt*:[Erdos65, page=41-43]")).
      to eq "Erdős, Heyting, and Brouwer 1965, pp. 41-43"
  end

  it "formats a single citation with a custom locator" do
    expect(formatted_citation("citealt*:[Erdos65, locator=somewhere]")).
      to eq "Erdős, Heyting, and Brouwer 1965, somewhere"
  end
end

describe "citealp macro" do
  it "formats a single citation" do
    expect(formatted_citation("citealp:[Erdos65]")).
      to eq "Erdős et al., 1965"
  end

  it "formats a grouped citation" do
    expect(formatted_citation("citealp:[Erdos65]+[Einstein35]")).
      to eq "Erdős et al., 1965; Einstein et al., 1935"
  end

  it "formats a single citation with a prefix" do
    expect(formatted_citation("citealp:[Erdos65, prefix=see]")).
      to eq "see Erdős et al., 1965"
  end

  it "formats a single citation with a suffix" do
    expect(formatted_citation("citealp:[Erdos65, suffix=new edition]")).
      to eq "Erdős et al., 1965, new edition"
  end

  it "formats a single citation with both a prefix and a suffix" do
    expect(formatted_citation("citealp:[Erdos65, prefix=see, suffix=new edition]")).
      to eq "see Erdős et al., 1965, new edition"
  end

  it "formats a single citation with a standard locator" do
    expect(formatted_citation("citealp:[Erdos65, page=41-43]")).
      to eq "Erdős et al., 1965, pp. 41-43"
  end

  it "formats a single citation with a custom locator" do
    expect(formatted_citation("citealp:[Erdos65, locator=somewhere]")).
      to eq "Erdős et al., 1965, somewhere"
  end
end

describe "citealp* macro" do
  it "formats a single citation" do
    expect(formatted_citation("citealp*:[Erdos65]")).
      to eq "Erdős, Heyting, and Brouwer, 1965"
  end

  it "formats a grouped citation" do
    expect(formatted_citation("citealp*:[Erdos65]+[Einstein35]")).
      to eq "Erdős, Heyting, and Brouwer, 1965; Einstein, Podolsky, and Rosen, 1935"
  end

  it "formats a single citation with a prefix" do
    expect(formatted_citation("citealp*:[Erdos65, prefix=see]")).
      to eq "see Erdős, Heyting, and Brouwer, 1965"
  end

  it "formats a single citation with a suffix" do
    expect(formatted_citation("citealp*:[Erdos65, suffix=new edition]")).
      to eq "Erdős, Heyting, and Brouwer, 1965, new edition"
  end

  it "formats a single citation with both a prefix and a suffix" do
    expect(formatted_citation("citealp*:[Erdos65, prefix=see, suffix=new edition]")).
      to eq "see Erdős, Heyting, and Brouwer, 1965, new edition"
  end

  it "formats a single citation with a standard locator" do
    expect(formatted_citation("citealp*:[Erdos65, page=41-43]")).
      to eq "Erdős, Heyting, and Brouwer, 1965, pp. 41-43"
  end

  it "formats a single citation with a custom locator" do
    expect(formatted_citation("citealp*:[Erdos65, locator=somewhere]")).
      to eq "Erdős, Heyting, and Brouwer, 1965, somewhere"
  end
end


