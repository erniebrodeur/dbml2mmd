# frozen_string_literal: true

module Dbml2mmd
  # Top-level schema object holding tables, relationships, etc.
  class Schema
    attr_reader :tables, :relationships

    def initialize(tables: [], relationships: [])
      @tables = tables
      @relationships = relationships
    end
  end
end
