# frozen_string_literal: true

require 'optparse'
require_relative 'errors'

module Dbml2mmd
  # Command Line Interface for dbml2mmd
  class CLI
    attr_reader :options

    def initialize
      @options = { output: nil }
    end

    def parse(args)
      opt_parser = OptionParser.new do |opts|
        opts.banner = 'Usage: dbml2mmd [options] <input_file>'

        opts.on('-o', '--output FILE', 'Output file path') do |file|
          @options[:output] = file
        end

        opts.on('-h', '--help', 'Show this message') do
          puts opts
          exit
        end

        opts.on('-v', '--version', 'Show version') do
          puts "dbml2mmd version #{Dbml2mmd::VERSION}"
          exit
        end
      end

      begin
        opt_parser.parse!(args)
        @options[:input] = args.shift

        raise Dbml2mmd::Errors::ParseError, 'Input file is required' unless @options[:input]

        unless File.exist?(@options[:input])
          raise Dbml2mmd::Errors::ParseError,
                "Input file does not exist: #{@options[:input]}"
        end

        @options
      rescue OptionParser::InvalidOption, OptionParser::MissingArgument => e
        raise Dbml2mmd::Errors::ParseError, e.message
      end
    end

    def run(args = ARGV)
      parse(args)

      input_content = File.read(@options[:input])
      output = convert_dbml_to_mermaid(input_content)

      if @options[:output]
        File.write(@options[:output], output)
      else
        puts output
      end
    end

    private

    def convert_dbml_to_mermaid(_content)
      # This would normally call the actual converter
      # For now, returning a placeholder
      "erDiagram\n  # Converted from DBML input"
    end
  end
end
