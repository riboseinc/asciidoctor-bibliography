# coding: utf-8

require_relative "citation_helper"

describe AsciidoctorBibliography::Index do
    describe ".render" do
        subject { described_class.new([], "default", "") }

        it "does not fail when no citations occur in the document" do
            options = { "bibliography-style" => "ieee", "bibliography-database" => "database.bibtex", "bibliography-passthrough" => "true", "bibliography-prepend-empty" => "false" }
            bibliographer = init_bibliographer options: options
            expect { subject.render bibliographer}.to_not raise_exception
        end
    end
end
