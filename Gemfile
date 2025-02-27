# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in dbml2mmd.gemspec
gemspec

# Development dependencies can stay in the Gemfile
group :development do
  gem "rake", "~> 13.0"
  gem "pry"
  gem "pry-byebug"
  gem "pry-doc"
  
  # Guard and plugins
  gem "guard"
  gem "guard-rspec"
  gem "guard-rubocop"
  
  # LSP and code quality
  gem "ruby-lsp", require: false
  gem "rubocop", "~> 1.21"
  gem "rubocop-rspec"
  gem "rubocop-performance"
  gem "rubocop-rake"
end

group :test do
  gem "rspec", "~> 3.0"
  gem "rspec-its"
  gem "simplecov"
  gem "simplecov-lcov"
end
