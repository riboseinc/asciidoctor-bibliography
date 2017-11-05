# coding: utf-8

require "asciidoctor-bibliography"
require_relative "../../../citation_helper"

describe "custom :adoc citeproc format" do
  let(:options) { { "bibliography-style" => "ieee", "bibliography-database" => "database.bib" } }

  it "adds space between first and second field" do
    expect(formatted_bibliography("cite:[Gettier63]", options: options)).
      to eq "[1] E. L. Gettier, “Is justified true belief knowledge?,” _analysis_, vol. 23, no. 6, pp. 121–123, 1963."
  end
end
