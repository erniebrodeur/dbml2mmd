# frozen_string_literal: true

module Dbml2mmd
  # Represents a single column in a table.
  class Column
    attr_reader :name, :type

    def initialize(name, type)
      @name = name
      @type = type
    end
  end
end
