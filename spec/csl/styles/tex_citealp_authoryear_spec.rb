# coding: utf-8

require_relative "../../citation_helper"

describe "citealp macro with authoryear style" do
  let(:options) { { "bibliography-tex-style" => "authoryear" } }

  it "formats a single citation" do
    expect(formatted_citation("citealp:[Erdos65]", options: options)).
      to eq "Erdős et al., 1965"
  end

  it "formats a grouped citation" do
    expect(formatted_citation("citealp:[Erdos65]+[Einstein35]", options: options)).
      to eq "Erdős et al., 1965; Einstein et al., 1935"
  end

  it "formats a single citation with a prefix" do
    expect(formatted_citation("citealp:[Erdos65, prefix=see]", options: options)).
      to eq "see Erdős et al., 1965"
  end

  it "formats a single citation with a suffix" do
    expect(formatted_citation("citealp:[Erdos65, suffix=new edition]", options: options)).
      to eq "Erdős et al., 1965, new edition"
  end

  it "formats a single citation with both a prefix and a suffix" do
    expect(formatted_citation("citealp:[Erdos65, prefix=see, suffix=new edition]", options: options)).
      to eq "see Erdős et al., 1965, new edition"
  end

  it "formats a single citation with a standard locator" do
    expect(formatted_citation("citealp:[Erdos65, page=41-43]", options: options)).
      to eq "Erdős et al., 1965, pp. 41-43"
  end

  it "formats a single citation with a custom locator" do
    expect(formatted_citation("citealp:[Erdos65, locator=somewhere]", options: options)).
      to eq "Erdős et al., 1965, somewhere"
  end
end
