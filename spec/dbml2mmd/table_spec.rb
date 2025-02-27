# frozen_string_literal: true

require "spec_helper"

RSpec.describe Dbml2Mmd::Table do
  describe "#initialize" do
    context "with only a name" do
      subject(:table) { described_class.new("users") }

      it "stores the table name" do
        expect(table.name).to eq("users")
      end

      it "defaults columns to an empty array" do
        expect(table.columns).to eq([])
      end
    end

    context "with columns provided" do
      let(:columns) { ["id", "email"] }
      subject(:table) { described_class.new("users", columns) }

      it "stores the columns" do
        expect(table.columns).to eq(["id", "email"])
      end
    end
  end
end
