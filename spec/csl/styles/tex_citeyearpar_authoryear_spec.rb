# coding: utf-8

require_relative "styles_helper"

describe "citeyearpar macro with authoryear style" do
  let(:options) {{ 'bibliography-tex-style' => 'authoryear'}}

  it "formats a single citation" do
    expect(formatted_citation("citeyearpar:[Erdos65]", options: options)).
      to eq "(1965)"
  end

  it "formats a grouped citation" do
    expect(formatted_citation("citeyearpar:[Erdos65]+[Einstein35]", options: options)).
      to eq "(1965; 1935)"
  end

  it "formats a single citation with a prefix" do
    expect(formatted_citation("citeyearpar:[Erdos65, prefix=see]", options: options)).
      to eq "(see 1965)"
  end

  it "formats a single citation with a suffix" do
    expect(formatted_citation("citeyearpar:[Erdos65, suffix=new edition]", options: options)).
      to eq "(1965, new edition)"
  end

  it "formats a single citation with both a prefix and a suffix" do
    expect(formatted_citation("citeyearpar:[Erdos65, prefix=see, suffix=new edition]", options: options)).
      to eq "(see 1965, new edition)"
  end

  it "formats a single citation with a standard locator" do
    expect(formatted_citation("citeyearpar:[Erdos65, page=41-43]", options: options)).
      to eq "(1965, pp. 41-43)"
  end

  it "formats a single citation with a custom locator" do
    expect(formatted_citation("citeyearpar:[Erdos65, locator=somewhere]", options: options)).
      to eq "(1965, somewhere)"
  end
end
