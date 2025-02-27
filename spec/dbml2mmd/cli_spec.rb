# spec/dbml2mmd/cli_spec.rb
# frozen_string_literal: true

require 'spec_helper'
require 'ostruct'
require 'optparse'

module Dbml2Mmd
  class CLI
    def parse_args(args)
      config = OpenStruct.new(
        help: false,
        direction: 'LR', # default
        title: nil,
        no_columns: false,
        hidden_tables: [],
        include_comments: false,
        ignore_enums: false,
        config_file: nil,
        dbml_file: nil,
        read_stdin: false,
        invalid_flag: nil
      )

      parser = OptionParser.new do |opts|
        opts.banner = 'Usage: dbml2mmd [OPTIONS] [DBML_FILE]'

        opts.on('-h', '--help', 'Show help message') do
          config.help = true
        end

        opts.on('--direction DIR', %w[LR TB RL], 'Diagram direction (LR|TB|RL)') do |dir|
          config.direction = dir
        end

        opts.on('-t', '--title TITLE', 'Include a title in the diagram') do |title|
          config.title = title
        end

        opts.on('--no-columns', 'Hide column definitions') do
          config.no_columns = true
        end

        opts.on('--hide TABLES', 'Comma-separated list of tables to exclude') do |value|
          config.hidden_tables = value.split(',').map(&:strip)
        end

        opts.on('--comments', 'Include DBML comments in output') do
          config.include_comments = true
        end

        opts.on('--ignore-enums', 'Skip enumerations') do
          config.ignore_enums = true
        end

        opts.on('--config-file FILE', 'Load advanced defaults from a config file') do |file|
          config.config_file = file
        end
      end

      begin
        parser.parse!(args)
      rescue OptionParser::InvalidOption
        config.invalid_flag = true
      end

      # After parse!, if there's leftover arguments, assume the first is DBML file
      if args.empty?
        config.read_stdin = true
      elsif args.size > 1
        config.invalid_flag = true
      else
        config.dbml_file = args.first
      end

      config
    end
  end
end

RSpec.describe 'Dbml2Mmd::CLI' do
  let(:cli) { Dbml2Mmd::CLI.new }

  describe '#parse_args' do
    context 'when no arguments are provided' do
      it 'reads from STDIN' do
        config = cli.parse_args([])
        expect(config.read_stdin).to be(true)
      end
    end

    context 'when a single DBML file is provided' do
      it 'assigns dbml_file' do
        config = cli.parse_args(['schema.dbml'])
        expect(config.dbml_file).to eq('schema.dbml')
      end

      it 'does not read from STDIN' do
        config = cli.parse_args(['schema.dbml'])
        expect(config.read_stdin).to be(false)
      end
    end

    context 'when more than one leftover argument is present' do
      it 'flags invalid_flag' do
        config = cli.parse_args(['schema.dbml', 'extra_arg'])
        expect(config.invalid_flag).to be(true)
      end
    end

    context 'with --help' do
      it 'sets help = true' do
        config = cli.parse_args(['--help'])
        expect(config.help).to be(true)
      end
    end

    context 'with --direction TB' do
      it 'sets the direction to TB' do
        config = cli.parse_args(['--direction', 'TB'])
        expect(config.direction).to eq('TB')
      end
    end

    context 'with --title' do
      it 'stores the title string' do
        config = cli.parse_args(['--title', 'My Diagram'])
        expect(config.title).to eq('My Diagram')
      end
    end

    context 'with --no-columns' do
      it 'sets no_columns to true' do
        config = cli.parse_args(['--no-columns'])
        expect(config.no_columns).to be(true)
      end
    end

    context "with --hide 'users,logs'" do
      it 'populates hidden_tables' do
        config = cli.parse_args(['--hide', 'users,logs'])
        expect(config.hidden_tables).to eq(%w[users logs])
      end
    end

    context 'with --comments' do
      it 'sets include_comments to true' do
        config = cli.parse_args(['--comments'])
        expect(config.include_comments).to be(true)
      end
    end

    context 'with --ignore-enums' do
      it 'sets ignore_enums to true' do
        config = cli.parse_args(['--ignore-enums'])
        expect(config.ignore_enums).to be(true)
      end
    end

    context 'with --config-file' do
      it 'stores the config_file path' do
        config = cli.parse_args(['--config-file', 'settings.yml'])
        expect(config.config_file).to eq('settings.yml')
      end
    end

    context 'with an invalid flag' do
      it 'marks invalid_flag as true' do
        config = cli.parse_args(['--not-a-real-flag'])
        expect(config.invalid_flag).to be(true)
      end
    end

    context 'with an invalid direction' do
      it 'marks invalid_flag as true' do
        # Attempt to parse a direction not in %w[LR TB RL]
        config = cli.parse_args(['--direction', 'XX'])
        expect(config.invalid_flag).to be(true)
      end
    end
  end
end
