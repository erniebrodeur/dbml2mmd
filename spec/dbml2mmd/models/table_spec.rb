# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dbml2mmd::Table do
  it 'stores a table name and columns' do
    table = described_class.new('users', %w[id email])
    expect(table.name).to eq('users')
    expect(table.columns).to eq(%w[id email])
  end
end
