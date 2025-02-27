# frozen_string_literal: true

module Dbml2mmd
  # Converts a Schema object into Mermaid 'erDiagram' syntax.
  class MermaidFormatter
    def format(schema, options = {})
      raise NotImplementedError, "MermaidFormatter#format is not implemented"
    end
  end
end
