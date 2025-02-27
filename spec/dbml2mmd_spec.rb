# frozen_string_literal: true

require "spec_helper"
require "dbml2mmd"

RSpec.describe Dbml2mmd do
  it "has a version number" do
    expect(Dbml2mmd::VERSION).not_to be_nil
  end

  it "loads all sub-modules without error" do
    # Basic sanity check: no exceptions raised when requiring sub-files
    expect { Dbml2mmd::Parser.new }.not_to raise_error
    expect { Dbml2mmd::Schema.new }.not_to raise_error
    expect { Dbml2mmd::Table.new("users") }.not_to raise_error
    expect { Dbml2mmd::Column.new("id", "int") }.not_to raise_error
    expect { Dbml2mmd::Relationship.new("users", "posts") }.not_to raise_error
    expect { Dbml2mmd::MermaidFormatter.new }.not_to raise_error
  end
end
