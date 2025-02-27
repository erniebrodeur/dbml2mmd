# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dbml2Mmd::Parser do
  describe '.parse' do
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

    it 'parses DBML content into a standard format' do
      result = described_class.parse(simple_dbml)

      # Check structure
      expect(result).to be_a(Hash)
      expect(result).to have_key(:tables)
      expect(result).to have_key(:refs)

      # Check tables
      expect(result[:tables].size).to eq(2)

      users_table = result[:tables].find { |t| t[:name] == 'users' }
      expect(users_table).to be_a(Hash)
      expect(users_table[:fields].size).to eq(3)

      # Check fields
      id_field = users_table[:fields].find { |f| f[:name] == 'id' }
      expect(id_field[:type]).to eq('integer')
      expect(id_field[:attributes]).to include('primary key')

      # Check references
      expect(result[:refs].size).to eq(1)
      ref = result[:refs].first
      expect(ref[:from][:table]).to eq('posts')
      expect(ref[:from][:field]).to eq('user_id')
      expect(ref[:to][:table]).to eq('users')
      expect(ref[:to][:field]).to eq('id')
    end

    context 'with different relationship types' do
      let(:relationship_dbml) do
        <<~DBML
          Table users {
            id integer [primary key]
          }

          Table posts {
            id integer [primary key]
            user_id integer
          }

          Table categories {
            id integer [primary key]
          }

          Table post_categories {
            post_id integer
            category_id integer
          }

          Ref: posts.user_id > users.id // one-to-many
          Ref: post_categories.post_id <> posts.id // many-to-many
        DBML
      end

      it 'correctly determines relationship types' do
        result = described_class.parse(relationship_dbml)

        one_to_many_rel = result[:refs].find { |r| r[:from][:field] == 'user_id' }
        expect(one_to_many_rel[:type]).to eq('many_to_one')

        many_to_many_rel = result[:refs].find { |r| r[:from][:field] == 'post_id' }
        expect(many_to_many_rel[:type]).to eq('many_to_many')
      end
    end
  end
end
