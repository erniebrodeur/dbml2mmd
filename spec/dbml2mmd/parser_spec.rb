# frozen_string_literal: true

require "spec_helper"
require "dbml2mmd/parser"

RSpec.describe Dbml2mmd::Parser do
  describe "#parse" do
    it "raises NotImplementedError by default" do
      parser = described_class.new
      expect {
        parser.parse("Table users {\n  id int\n}")
      }.to raise_error(NotImplementedError)
    end
  end
end
