# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dbml2mmd::Column do
  it 'stores a column name and type' do
    column = described_class.new('id', 'int')
    expect(column.name).to eq('id')
    expect(column.type).to eq('int')
  end
end
