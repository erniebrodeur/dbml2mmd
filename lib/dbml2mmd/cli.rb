# frozen_string_literal: true

module Dbml2Mmd
  class CLI
    attr_reader :options, :opts, :exit_code

    def initialize(args, output: $stdout, error_output: $stderr)
      @args = args
      @output = output
      @error_output = error_output
      @exit_requested = false
      @exit_code = 0
    end

    def run
      parse_options
      return @exit_code if @exit_requested

      result = process_input
      output_result(result)
      @exit_code
    rescue Slop::Error => e
      handle_error("Error: #{e.message}", show_opts: true)
      @exit_code
    rescue StandardError => e
      handle_error("Error: #{e.message}", backtrace: e.backtrace, show_opts: true)
      @exit_code
    end

    # For testing purposes
    def exit_requested?
      @exit_requested
    end

    private

    def parse_options
      @opts = Slop::Options.new
      @opts.banner = 'Usage: dbml2mmd [options] [input_file]'

      @opts.separator "\nOptions:"
      @opts.string '-o', '--output', 'Output to file instead of stdout'
      @opts.bool '-h', '--help', 'Show this help message'
      @opts.string '-t', '--theme', 'Mermaid theme (default, dark, neutral, forest)', default: 'default'
      @opts.bool '--html', 'Generate HTML output with embedded Mermaid viewer'
      @opts.string '--only', 'Only include specific tables (comma-separated list)'
      @opts.bool '-v', '--verbose', 'Enable verbose output'
      @opts.on '--version', 'Print the version' do
        @output.puts "DBML to Mermaid Converter v#{Dbml2Mmd::VERSION}"
        @exit_requested = true
        @exit_code = 0
        return
      end

      @opts.separator "\nExamples:"
      @opts.separator '  dbml2mmd input.dbml                    # Convert file and output to stdout'
      @opts.separator '  dbml2mmd -o output.mmd input.dbml      # Convert file and save to output.mmd'
      @opts.separator '  dbml2mmd --html -o output.html input.dbml  # Generate HTML with Mermaid viewer'
      @opts.separator '  dbml2mmd --theme dark input.dbml       # Use dark theme for diagram'
      @opts.separator '  dbml2mmd --only users,posts input.dbml # Only include specific tables'
      @opts.separator '  cat input.dbml | dbml2mmd              # Read from stdin and output to stdout'

      parser = Slop::Parser.new(@opts)
      @options_parsed = parser.parse(@args)

      @options = {
        theme: @options_parsed[:theme],
        html_output: @options_parsed[:html],
        only_tables: @options_parsed[:only],
        verbose: @options_parsed[:verbose],
        output: @options_parsed[:output] # Add output to options hash
      }

      # Show help by default when no arguments are provided
      return unless (@args.empty? && $stdin.tty?) || @options_parsed.help?

      @output.puts @opts
      @exit_requested = true
      @exit_code = 0
    end

    def process_input
      # Get input from file or stdin
      input = get_input
      return nil unless input

      # Print verbose info if enabled
      output_verbose_info if @options[:verbose]

      # Convert DBML to Mermaid
      converter = create_converter
      result = converter.convert(input)

      {
        mermaid: result,
        converter: converter
      }
    end

    def get_input
      if input_file
        begin
          File.read(input_file)
        rescue Errno::ENOENT => e
          handle_error("Error: #{e.message}")
          nil
        end
      else
        $stdin.tty? ? nil : $stdin.read
      end
    end

    def input_file
      # Find the last argument that isn't an option
      @args.reject { |arg| arg.start_with?('-') }.last
    end

    def create_converter
      Dbml2Mmd::Converter.new(@options)
    end

    def output_verbose_info
      @output.puts "Input source: #{@args.empty? ? 'STDIN' : @args[0]}"
      @output.puts "Theme: #{@options[:theme]}"
      @output.puts "HTML output: #{@options[:html_output]}"
      @output.puts "Filtering tables: #{@options[:only_tables] || 'No'}"
    end

    def output_result(result)
      return unless result

      if @options[:output]
        output_content = @options[:html_output] ? result[:converter].output_html : result[:mermaid]
        File.write(@options[:output], output_content)
        @output.puts "Output written to #{@options[:output]}"
      else
        @output.puts result[:mermaid]
      end
    end

    def handle_error(message, backtrace: nil, show_opts: false)
      @error_output.puts message
      @error_output.puts backtrace if backtrace && @options&.fetch(:verbose, false)
      @error_output.puts @opts if show_opts && @opts
      @exit_code = 1
    end
  end
end
