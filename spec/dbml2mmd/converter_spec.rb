require 'spec_helper'

RSpec.describe Dbml2Mmd::Converter do
  subject(:converter) { described_class.new }

  describe '#convert' do
    context 'with valid DBML input' do
      context 'with a simple table' do
        let(:dbml) do
          <<~DBML
            Table users {
              id integer [primary key]
              username varchar
              email varchar
            }
          DBML
        end

        let(:expected_output) do
          <<~MMD
            ```mermaid
            erDiagram
              users {
                integer id PK
                varchar username
                varchar email
              }
            ```
          MMD
        end

        it 'converts to mermaid markdown correctly' do
          expect(converter.convert(dbml)).to eq(expected_output)
        end
      end

      context 'with table relationships' do
        let(:dbml) do
          <<~DBML
            Table users {
              id integer [primary key]
              username varchar
            }

            Table posts {
              id integer [primary key]
              user_id integer
              title varchar
              content text
            }

            Ref: posts.user_id > users.id
          DBML
        end

        it 'includes both tables in the output' do
          result = converter.convert(dbml)
          expect(result).to include('users {')
          expect(result).to include('posts {')
        end

        it 'represents the relationship correctly' do
          expect(converter.convert(dbml)).to include('posts ||--o{ users : "user_id > id"')
        end
      end

      context 'with multiple relationship types' do
        let(:dbml) do
          <<~DBML
            Table authors {
              id integer [primary key]
              name varchar
            }

            Table books {
              id integer [primary key]
              title varchar
            }

            Table author_books {
              author_id integer
              book_id integer
            }

            Ref: author_books.author_id > authors.id
            Ref: author_books.book_id > books.id
          DBML
        end

        it 'represents all relationships correctly' do
          result = converter.convert(dbml)
          expect(result).to include('author_books ||--o{ authors')
          expect(result).to include('author_books ||--o{ books')
        end
      end

      context 'with indexes and constraints' do
        let(:dbml) do
          <<~DBML
            Table users {
              id integer [primary key]
              email varchar [unique]
              created_at timestamp

              indexes {
                email [unique]
                (id, created_at) [name: 'composite_idx']
              }
            }
          DBML
        end

        it 'preserves the table structure' do
          result = converter.convert(dbml)
          expect(result).to include('integer id PK')
          expect(result).to include('varchar email')
          expect(result).to include('timestamp created_at')
        end
      end

      context 'with notes and comments' do
        let(:dbml) do
          <<~DBML
            Table users {
              id integer [primary key, note: 'User ID']
              email varchar [note: 'Email address']
            }

            // This is a comment
          DBML
        end

        it 'preserves the table structure while ignoring comments' do
          result = converter.convert(dbml)
          expect(result).to include('integer id PK')
          expect(result).to include('varchar email')
        end
      end
    end

    context 'with invalid DBML input' do
      let(:invalid_dbml) { 'This is not valid DBML' }

      it 'raises a ParseError' do
        expect { converter.convert(invalid_dbml) }.to raise_error(Dbml2Mmd::ParseError)
      end
    end
  end
end
