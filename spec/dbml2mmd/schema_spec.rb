# frozen_string_literal: true

require "spec_helper"
require "dbml2mmd/table"
require "dbml2mmd/relationship"

RSpec.describe Dbml2Mmd::Schema do
  describe "#initialize" do
    context "with no tables or relationships" do
      subject(:schema) { described_class.new }

      it "defaults tables to an empty array" do
        expect(schema.tables).to eq([])
      end

      it "defaults relationships to an empty array" do
        expect(schema.relationships).to eq([])
      end
    end

    context "with tables and relationships" do
      let(:users_table) { Dbml2Mmd::Table.new("users") }
      let(:posts_table) { Dbml2Mmd::Table.new("posts") }
      let(:rel) { Dbml2Mmd::Relationship.new("users", "posts") }

      subject(:schema) do
        described_class.new(
          tables: [users_table, posts_table],
          relationships: [rel]
        )
      end

      it "stores the given tables" do
        table_names = schema.tables.map(&:name)
        expect(table_names).to match_array(%w[users posts])
      end

      it "stores the given relationships" do
        expect(schema.relationships.size).to eq(1)
      end
    end
  end
end
