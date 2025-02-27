# frozen_string_literal: true

require "spec_helper"

RSpec.describe Dbml2Mmd::Relationship do
  describe "#initialize" do
    context "with two table names" do
      subject(:rel) { described_class.new("users", "posts") }

      it "stores the left_table" do
        expect(rel.left_table).to eq("users")
      end

      it "stores the right_table" do
        expect(rel.right_table).to eq("posts")
      end

      it "defaults constraint to nil" do
        expect(rel.constraint).to be_nil
      end
    end

    context "with a constraint" do
      subject(:rel) { described_class.new("users", "posts", constraint: "1-to-many") }

      it "stores the constraint" do
        expect(rel.constraint).to eq("1-to-many")
      end
    end
  end
end
