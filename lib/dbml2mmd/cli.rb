require "slop"
require "dbml2mmd/version"

module Dbml2Mmd
  class CLI
    def initialize(args)
      @args = args
    end

    def run
      parse_options
      process_input
    rescue Slop::Error => e
      puts "Error: #{e.message}"
      puts @opts
      exit 1
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace if @options&.verbose?
      puts @opts if @opts
      exit 1
    end

    private

    def parse_options
      @opts = Slop.parse(@args) do |o|
        o.banner = "Usage: dbml2mmd [options] [input_file]"
        
        o.string '-o', '--output', 'Output to file instead of stdout'
        o.bool '-h', '--help', 'Show this help message', default: false
        o.string '-t', '--theme', 'Mermaid theme (default, dark, neutral, forest)', default: 'default'
        o.bool '--html', 'Generate HTML output with embedded Mermaid viewer', default: false
        o.string '--only', 'Only include specific tables (comma-separated list)'
        o.bool '-v', '--verbose', 'Enable verbose output', default: false
        
        o.on '--version', 'Print the version' do
          puts "DBML to Mermaid Converter v#{Dbml2Mmd::VERSION}"
          exit
        end
      end
      
      @options = {
        theme: @opts[:theme],
        html_output: @opts[:html],
        only_tables: @opts[:only],
        verbose: @opts[:verbose]
      }

      # Show help by default when no arguments are provided
      if (@args.empty? && STDIN.tty?) || @opts.help?
        show_help
        exit
      end
    end
    
    def show_help
      puts @opts
      puts "\nExamples:"
      puts "  dbml2mmd input.dbml                    # Convert file and output to stdout"
      puts "  dbml2mmd -o output.mmd input.dbml      # Convert file and save to output.mmd"
      puts "  dbml2mmd --html -o output.html input.dbml  # Generate HTML with Mermaid viewer"
      puts "  dbml2mmd --theme dark input.dbml       # Use dark theme for diagram"
      puts "  dbml2mmd --only users,posts input.dbml # Only include specific tables"
      puts "  cat input.dbml | dbml2mmd              # Read from stdin and output to stdout"
    end

    def process_input
      # Get input from file or stdin
      input = if @args.empty?
        ARGF.read
      else
        begin
          File.read(@args[0])
        rescue Errno::ENOENT
          puts "Error: File not found: #{@args[0]}"
          exit 1
        end
      end
      
      # Print verbose info if enabled
      if @options[:verbose]
        puts "Input source: #{@args.empty? ? 'STDIN' : @args[0]}"
        puts "Theme: #{@options[:theme]}"
        puts "HTML output: #{@options[:html]}"
        puts "Filtering tables: #{@options[:only] || 'No'}"
      end
      
      # Convert DBML to Mermaid
      converter = Dbml2Mmd::Converter.new(@options)
      mermaid = converter.convert(input)
      
      # Output result
      if @opts[:output]
        output = @opts[:html] ? converter.output_html : mermaid
        File.write(@opts[:output], output)
        puts "Output written to #{@opts[:output]}"
      else
        puts mermaid
      end
    end
  end
end
