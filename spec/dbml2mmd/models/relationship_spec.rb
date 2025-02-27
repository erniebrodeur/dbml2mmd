# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dbml2mmd::Relationship do
  it 'stores left_table, right_table, and an optional constraint' do
    rel = described_class.new('users', 'posts', constraint: '1-to-many')
    expect(rel.left_table).to eq('users')
    expect(rel.right_table).to eq('posts')
    expect(rel.constraint).to eq('1-to-many')
  end
end
