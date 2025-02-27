# frozen_string_literal: true

RSpec.describe Dbml2mmd do
  it 'has a version number' do
    expect(Dbml2mmd::VERSION).not_to be nil
  end

  describe 'integration test' do
    let(:simple_dbml) do
      <<~DBML
        Table users {
          id integer [primary key]
          username varchar
        }

        Table posts {
          id integer [primary key]
          title varchar
          user_id integer
        }

        Ref: posts.user_id > users.id
      DBML
    end

    it 'converts DBML to Mermaid diagram' do
      # Parse the DBML content
      parsed = Dbml2mmd::Parser.parse(simple_dbml)

      # Verify parsing result
      expect(parsed[:tables].size).to eq(2)
      expect(parsed[:refs].size).to eq(1)

      # Convert to Mermaid
      converter = Dbml2mmd::Converter.new
      result = converter.convert(simple_dbml)

      # Check Mermaid output
      expect(result).to include('erDiagram')
      expect(result).to include('users {')
      expect(result).to include('posts {')
      expect(result).to match(/posts\s+\}o--\|\|\s+users/)
    end
  end
end
