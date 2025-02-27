# frozen_string_literal: true

module Dbml2mmd
  # Represents a relationship (foreign key / reference) between two tables.
  class Relationship
    attr_reader :left_table, :right_table, :constraint

    def initialize(left_table, right_table, constraint: nil)
      @left_table = left_table
      @right_table = right_table
      @constraint = constraint
    end
  end
end
