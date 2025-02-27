# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dbml2mmd::Schema do
  it 'initializes with tables and relationships' do
    schema = described_class.new(tables: [], relationships: [])
    expect(schema.tables).to eq([])
    expect(schema.relationships).to eq([])
  end
end
