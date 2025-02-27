# frozen_string_literal: true

require "spec_helper"
require "dbml2mmd/table"

RSpec.describe Dbml2mmd::Table do
  it "stores a table name and columns" do
    table = described_class.new("users", ["id", "email"])
    expect(table.name).to eq("users")
    expect(table.columns).to eq(["id", "email"])
  end
end
