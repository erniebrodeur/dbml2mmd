# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dbml2Mmd::Converter do
  let(:simple_dbml) do
    <<~DBML
      Table users {
        id integer [primary key]
        username varchar
        email varchar
      }

      Table posts {
        id integer [primary key]
        title varchar
        content text
        user_id integer
      }

      Ref: posts.user_id > users.id
    DBML
  end

  describe '#convert' do
    it 'converts DBML to Mermaid ERD format' do
      converter = described_class.new
      result = converter.convert(simple_dbml)

      # Check for Mermaid ERD header
      expect(result).to include('erDiagram')

      # Check for tables
      expect(result).to include('users {')
      expect(result).to include('posts {')

      # Check for fields
      expect(result).to include('id integer PK')
      expect(result).to include('user_id integer FK')

      # Check for relationship
      expect(result).to match(/posts\s+\}o--\|\|\s+users/)
    end

    context 'with theme options' do
      it 'applies the dark theme configuration when specified' do
        converter = described_class.new(theme: 'dark')
        result = converter.convert(simple_dbml)

        expect(result).to include("'theme': 'dark'")
        expect(result).to include("'primaryColor': '#2A2A2A'")
      end

      it 'applies the default theme when no theme is specified' do
        converter = described_class.new
        result = converter.convert(simple_dbml)

        expect(result).to include("'theme': 'default'")
      end
    end

    context 'with table filtering' do
      it 'only includes specified tables' do
        converter = described_class.new(only_tables: 'users')
        result = converter.convert(simple_dbml)

        expect(result).to include('users {')
        expect(result).not_to include('posts {')
        expect(result).not_to match(/posts\s+\}o--\|\|\s+users/)
      end
    end
  end

  describe '#output_html' do
    it 'returns nil when html_output is not set' do
      converter = described_class.new
      converter.convert(simple_dbml)

      expect(converter.output_html).to be_nil
    end

    it 'generates HTML output when html_output is set' do
      converter = described_class.new(html_output: true)
      converter.convert(simple_dbml)

      html = converter.output_html
      expect(html).to include('<!DOCTYPE html>')
      expect(html).to include('mermaid.initialize')
      expect(html).to include('erDiagram')
    end
  end
end
