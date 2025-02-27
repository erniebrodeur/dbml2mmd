# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in dbml2mmd.gemspec
gemspec

# Development dependencies can stay in the Gemfile
group :development do
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-doc'
  gem 'rake', '~> 13.0'

  # Guard and plugins
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-rubocop'

  # LSP and code quality
  gem 'rubocop', '~> 1.21'
  gem 'rubocop-performance'
  gem 'rubocop-rake'
  gem 'rubocop-rspec'
  gem 'ruby-lsp', require: false
end

group :test do
  gem 'rspec', '~> 3.0'
  gem 'rspec-its'
  gem 'simplecov'
  gem 'simplecov-lcov'
end
