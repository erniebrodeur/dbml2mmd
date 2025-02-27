# frozen_string_literal: true

require 'spec_helper'
require 'dbml2mmd/parser'
require 'dbml2mmd/errors'

RSpec.describe Dbml2mmd::Parser do
  subject(:parser) { described_class.new }

  describe '#parse' do
    context 'with a single table fixture' do
      let(:input) { read_fixture('single_table.dbml') }
      let(:schema) { parser.parse(input) }

      it 'detects one table' do
        expect(schema.tables.size).to eq(1)
      end

      it 'parses the table name' do
        expect(schema.tables.first.name).to eq('users')
      end

      it 'has two columns' do
        expect(schema.tables.first.columns.size).to eq(2)
      end

      it 'parses the column names' do
        names = schema.tables.first.columns.map(&:name)
        expect(names).to eq(%w[id email])
      end
    end

    context 'with multiple tables and a reference' do
      let(:input) { read_fixture('multi_table.dbml') }
      let(:schema) { parser.parse(input) }

      it 'finds both tables' do
        table_names = schema.tables.map(&:name)
        expect(table_names).to match_array(%w[users posts])
      end

      it 'has exactly one relationship' do
        expect(schema.relationships.size).to eq(1)
      end

      it 'parses the reference correctly' do
        rel = schema.relationships.first
        expect([rel.left_table, rel.right_table]).to match_array(%w[posts users])
      end
    end

    context 'with an invalid schema fixture' do
      let(:input) { read_fixture('invalid_schema.dbml') }

      it 'raises a ParseError' do
        expect { parser.parse(input) }.to raise_error(Dbml2mmd::Errors::ParseError)
      end
    end
  end
end
