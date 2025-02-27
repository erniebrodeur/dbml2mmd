# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dbml2Mmd::Parser do
  describe '.parse' do
    subject(:parsed_result) { described_class.parse(dbml_content) }
    
    let(:dbml_content) { 'Table users { id integer [pk] }' }
    let(:parser_double) { instance_double(DBML::Parser) }
    let(:dbml_result) do
      instance_double('DBML::Result',
                      tables: [table_double],
                      refs: [])
    end
    let(:table_double) do
      instance_double('DBML::Table',
                      name: 'users',
                      columns: [column_double])
    end
    let(:column_double) do
      instance_double('DBML::Column',
                      name: 'id',
                      type: 'integer',
                      settings: ['pk'])
    end

    before do
      allow(DBML::Parser).to receive(:new).and_return(parser_double)
      allow(parser_double).to receive(:parse).with(dbml_content).and_return(dbml_result)
    end

    it { is_expected.to be_a(Hash) }

    it 'contains tables array' do
      expect(parsed_result[:tables]).to be_an(Array)
    end

    it 'contains references array' do
      expect(parsed_result[:refs]).to be_an(Array)
    end

    context 'when converting to standard format' do
      it 'preserves table name' do
        expect(parsed_result[:tables].first[:name]).to eq('users')
      end

      it 'preserves field name' do
        expect(parsed_result[:tables].first[:fields].first[:name]).to eq('id')
      end

      it 'preserves field type' do
        expect(parsed_result[:tables].first[:fields].first[:type]).to eq('integer')
      end

      it 'preserves field attributes' do
        expect(parsed_result[:tables].first[:fields].first[:attributes]).to eq('pk')
      end
    end
  end

  describe '.convert_to_standard_format' do
    subject(:standard_format) { described_class.convert_to_standard_format(dbml_result) }

    let(:dbml_result) do
      OpenStruct.new(
        tables: [users_table, posts_table],
        refs: [user_posts_ref]
      )
    end
    let(:users_table) do
      OpenStruct.new(
        name: 'users',
        columns: [
          OpenStruct.new(name: 'id', type: 'integer', settings: ['pk']),
          OpenStruct.new(name: 'email', type: 'varchar', settings: ['unique'])
        ]
      )
    end
    let(:posts_table) do
      OpenStruct.new(
        name: 'posts',
        columns: [
          OpenStruct.new(name: 'id', type: 'integer', settings: ['pk']),
          OpenStruct.new(name: 'user_id', type: 'integer', settings: [])
        ]
      )
    end
    let(:user_posts_ref) do
      OpenStruct.new(
        endpoints: [
          OpenStruct.new(tableName: 'users', columnName: 'id', relation: '1'),
          OpenStruct.new(tableName: 'posts', columnName: 'user_id', relation: '*')
        ]
      )
    end

    context 'when converting tables' do
      it 'includes correct number of tables' do
        expect(standard_format[:tables].size).to eq(2)
      end

      it 'preserves table names' do
        expect(standard_format[:tables][0][:name]).to eq('users')
      end

      it 'includes all fields for each table' do
        expect(standard_format[:tables][0][:fields].size).to eq(2)
      end

      it 'preserves field attributes' do
        expect(standard_format[:tables][0][:fields][0][:name]).to eq('id')
        expect(standard_format[:tables][0][:fields][0][:type]).to eq('integer')
        expect(standard_format[:tables][0][:fields][0][:attributes]).to eq('pk')
      end
    end

    context 'when converting references' do
      it 'includes correct number of references' do
        expect(standard_format[:refs].size).to eq(1)
      end

      it 'preserves source table and field' do
        expect(standard_format[:refs][0][:from][:table]).to eq('users')
        expect(standard_format[:refs][0][:from][:field]).to eq('id')
      end

      it 'preserves target table and field' do
        expect(standard_format[:refs][0][:to][:table]).to eq('posts')
        expect(standard_format[:refs][0][:to][:field']).to eq('user_id')
      end

      it 'determines correct relationship type' do
        expect(standard_format[:refs][0][:type]).to eq('one_to_many')
      end
    end
  end

  describe '.determine_relationship_type' do
    subject(:relationship_type) { described_class.determine_relationship_type(reference) }

    context 'with one-to-one relationship' do
      let(:reference) do
        OpenStruct.new(
          endpoints: [
            OpenStruct.new(relation: '1'),
            OpenStruct.new(relation: '1')
          ]
        )
      end

      it { is_expected.to eq('one_to_one') }
    end

    context 'with one-to-many relationship' do
      let(:reference) do
        OpenStruct.new(
          endpoints: [
            OpenStruct.new(relation: '1'),
            OpenStruct.new(relation: '*')
          ]
        )
      end

      it { is_expected.to eq('one_to_many') }
    end

    context 'with many-to-one relationship' do
      let(:reference) do
        OpenStruct.new(
          endpoints: [
            OpenStruct.new(relation: '*'),
            OpenStruct.new(relation: '1')
          ]
        )
      end

      it { is_expected.to eq('many_to_one') }
    end

    context 'with many-to-many relationship' do
      let(:reference) do
        OpenStruct.new(
          endpoints: [
            OpenStruct.new(relation: '*'),
            OpenStruct.new(relation: '*')
          ]
        )
      end

      it { is_expected.to eq('many_to_many') }
    end
  end
end
