# frozen_string_literal: true

require "spec_helper"
require "dbml2mmd/mermaid_formatter"
require "dbml2mmd/schema"

RSpec.describe Dbml2mmd::MermaidFormatter do
  describe "#format" do
    it "raises NotImplementedError by default" do
      formatter = described_class.new
      schema = Dbml2mmd::Schema.new
      expect { formatter.format(schema) }.to raise_error(NotImplementedError)
    end
  end
end
