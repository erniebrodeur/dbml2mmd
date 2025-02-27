# frozen_string_literal: true

require "spec_helper"

RSpec.describe Dbml2Mmd::Column do
  describe "#initialize" do
    context "with a name and type" do
      subject(:column) { described_class.new("id", "int") }

      it "stores the column name" do
        expect(column.name).to eq("id")
      end

      it "stores the column type" do
        expect(column.type).to eq("int")
      end
    end
  end
end
