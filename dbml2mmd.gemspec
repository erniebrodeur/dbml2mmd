# frozen_string_literal: true

require_relative 'lib/dbml2mmd/version'

Gem::Specification.new do |spec|
  spec.name          = 'dbml2mmd'
  spec.version       = Dbml2Mmd::VERSION
  spec.authors       = ['Ernie Brodeur']
  spec.email         = ['ebrodeur@ujami.net']

  spec.summary       = 'Convert DBML database schemas to Mermaid ERD diagrams'
  spec.description   = 'A tool to convert Database Markup Language (DBML) schemas to Mermaid Entity Relationship Diagrams (ERD) for visualization'
  spec.homepage      = 'https://github.com/erniebrodeur/dbml2mmd'
  spec.license       = 'GPL-3.0-or-later'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage.to_s
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['documentation_uri'] = 'https://erniebrodeur.github.io/dbml2mmd/'
  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/issues"

  spec.files         = Dir.glob('{bin,lib,exe}/**/*') + %w[LICENSE README.md]
  spec.bindir        = 'exe'
  spec.executables   = ['dbml2mmd']
  spec.require_paths = ['lib']

  # Runtime dependencies
  spec.add_dependency 'dbml', '~> 0.1'
  spec.add_dependency 'slop', '~> 4.0'
end
