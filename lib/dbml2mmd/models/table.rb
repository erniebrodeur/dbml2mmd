# frozen_string_literal: true

module Dbml2mmd
  # Represents a single database table with columns.
  class Table
    attr_reader :name, :columns

    def initialize(name, columns = [])
      @name = name
      @columns = columns
    end
  end
end
