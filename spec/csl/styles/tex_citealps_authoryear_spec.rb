# coding: utf-8

require_relative "styles_helper"

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


