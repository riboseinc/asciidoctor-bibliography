# coding: utf-8

require_relative "citation_helper"

describe "cite macro with apa style" do
  it "formats a complex citation" do
    expect(formatted_citation("cite:[Erdos65, prefix=see]+[Einstein35, page=41-43]",
                              options: { "bibliography-style" => "apa",
                                         "bibliography-database" => "database.bib",
                                         "bibliography-hyperlinks" => "true" })).
      to eq "(<<bibliography-default-Einstein35,Einstein, Podolsky, & Rosen, 1935, pp. 41-43>>; " +
      "<<bibliography-default-Erdos65,seeErdős, Heyting, & Brouwer, 1965>>)"
  end
end

describe "cite macro with arbitrary interpolated text" do
  it "formats a complex citation" do
    expect(formatted_citation("cite:[Erdos65, text=foo {cite} bar]",
                              options: { "bibliography-style" => "apa",
                                         "bibliography-database" => "database.bib",
                                         "bibliography-hyperlinks" => "true" })).
      to eq "(<<bibliography-default-Erdos65,foo Erdős, Heyting, & Brouwer, 1965 bar>>)"
  end
end

describe "fullcite macro with apa style" do
  it "formats a complex citation" do
    expect(formatted_citation("fullcite:[Erdos65]",
                              options: { "bibliography-style" => "apa",
                                         "bibliography-database" => "database.bib" })).
      to eq "Erdős, P., Heyting, A., & Brouwer, L. E. (1965). Some very hard sums. _Difficult Maths Today_, 30."
  end
end

describe "cite macro using an unknown key" do
  it "formats bold question marks" do
    expect(formatted_citation("cite:[Erdos65]+[foobar]",
                              options: { "bibliography-style" => "apa",
                                         "bibliography-database" => "database.bib",
                                         "bibliography-hyperlinks" => "true" })).
      to eq "*??*"
  end
end

describe "cite macro using more than two keys" do
  it "formats all cited keys" do
    expect(formatted_citation("cite:[Lane12a]+[Lane12b]+[Erdos65]+[Einstein35]",
                              options: { "bibliography-style" => "apa",
                                         "bibliography-database" => "database.bib",
                                         "bibliography-hyperlinks" => "true" })).
      to eq "(<<bibliography-default-Einstein35,Einstein, Podolsky, & Rosen, 1935>>; <<bibliography-default-Erdos65,Erdős, Heyting, & Brouwer, 1965>>; <<bibliography-default-Lane12a,Lane, 2000>>; <<bibliography-default-Lane12b,Mane & Smith, 2000>>)"
  end
end
