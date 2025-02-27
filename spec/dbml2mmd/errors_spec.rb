# frozen_string_literal: true

require "spec_helper"
require "dbml2mmd/errors"

RSpec.describe Dbml2mmd::Errors do
  subject { described_class }

  it "is a module" do
    is_expected.to be_a(Module)
  end

  describe "::ParseError" do
    it "inherits from StandardError" do
      expect(described_class::ParseError.superclass).to eq(StandardError)
    end
  end
end
