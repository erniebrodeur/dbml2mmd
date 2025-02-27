require "dbml"

module Dbml2Mmd
  class Parser
    def self.parse(content)
      # Use the dbml gem (required dependency)
      parser = DBML::Parser.new
      result = parser.parse(content)
      convert_to_standard_format(result)
    end
    
    # Convert dbml gem output to standard format
    def self.convert_to_standard_format(result)
      standard = { tables: [], refs: [] }
      
      # Process tables
      result.tables.each do |table|
        fields = table.columns.map do |column|
          {
            name: column.name,
            type: column.type,
            attributes: column.settings&.join(',')
          }
        end
        
        standard[:tables] << {
          name: table.name,
          fields: fields
        }
      end
      
      # Process references
      result.refs.each do |ref|
        endpoint1 = ref.endpoints.first
        endpoint2 = ref.endpoints.last
        
        standard[:refs] << {
          from: { table: endpoint1.tableName, field: endpoint1.columnName },
          to: { table: endpoint2.tableName, field: endpoint2.columnName },
          type: determine_relationship_type(ref)
        }
      end
      
      standard
    end
    
    # Determine relationship type from dbml gem reference
    def self.determine_relationship_type(ref)
      endpoint1, endpoint2 = ref.endpoints.first, ref.endpoints.last
      
      case [endpoint1.relation, endpoint2.relation]
      when ['1', '1'] then 'one_to_one'
      when ['1', '*'] then 'one_to_many'
      when ['*', '1'] then 'many_to_one'
      when ['*', '*'] then 'many_to_many'
      else 'one_to_one' # Default
      end
    end
  end
end
