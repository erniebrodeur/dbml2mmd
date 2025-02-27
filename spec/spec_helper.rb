# frozen_string_literal: true

require 'simplecov'
require 'simplecov-lcov'
require 'ostruct'
require 'bundler/setup'
require 'dbml2mmd'

# Configure SimpleCov + LCOV
SimpleCov::Formatter::LcovFormatter.config do |c|
  c.report_with_single_file = true
  c.single_report_path = 'coverage/lcov.info'
end

SimpleCov.start do
  add_filter '/spec/'
  minimum_coverage 90
  enable_coverage :branch
  formatter SimpleCov::Formatter::MultiFormatter.new([
                                                       SimpleCov::Formatter::HTMLFormatter,
                                                       SimpleCov::Formatter::LcovFormatter
                                                     ])
end

# Optional: define a helper module for loading fixtures
module FixtureHelper
  def fixture_path(filename)
    File.join(File.dirname(__FILE__), 'fixtures', filename)
  end

  def read_fixture(filename)
    File.read(fixture_path(filename))
  end
end

RSpec.configure do |config|
  # Include our fixture helper so specs can call read_fixture('some.dbml')
  config.include FixtureHelper

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = 'tmp/.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
