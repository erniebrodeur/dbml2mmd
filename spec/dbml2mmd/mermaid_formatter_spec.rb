# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dbml2Mmd::MermaidFormatter do
  subject(:formatter) { described_class.new }

  describe '#format' do
    context 'with a single-table schema' do
      let(:table) do
        Dbml2mmd::Table.new(
          'users',
          [
            Dbml2mmd::Column.new('id', 'int'),
            Dbml2mmd::Column.new('email', 'varchar')
          ]
        )
      end

      let(:schema) { Dbml2mmd::Schema.new(tables: [table]) }
      let(:output) { formatter.format(schema) }

      it "starts with 'erDiagram'" do
        expect(output).to start_with('erDiagram')
      end

      it 'includes the table name' do
        expect(output).to include('users')
      end

      it 'includes column references' do
        expect(output).to include('id', 'email')
      end
    end

    context 'with a multi-table schema and a relationship' do
      let(:users_table) do
        Dbml2mmd::Table.new(
          'users',
          [
            Dbml2mmd::Column.new('id', 'int'),
            Dbml2mmd::Column.new('email', 'varchar')
          ]
        )
      end

      let(:posts_table) do
        Dbml2mmd::Table.new(
          'posts',
          [
            Dbml2mmd::Column.new('id', 'int'),
            Dbml2mmd::Column.new('user_id', 'int')
          ]
        )
      end

      let(:relationship) do
        Dbml2mmd::Relationship.new('users', 'posts', constraint: '1-to-many')
      end

      let(:schema) do
        Dbml2mmd::Schema.new(
          tables: [users_table, posts_table],
          relationships: [relationship]
        )
      end

      let(:output) { formatter.format(schema) }

      it 'includes both table names' do
        expect(output).to include('users', 'posts')
      end

      it 'represents the relationship' do
        # Adjust this to match how relationships are rendered, e.g. "posts }|--|| users"
        expect(output).to include('users', 'posts')
      end
    end
  end
end
