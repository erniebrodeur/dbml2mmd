# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'

RSpec.describe Dbml2Mmd::CLI do
  let(:simple_dbml) do
    <<~DBML
      Table users {
        id integer [primary key]
        username varchar
      }
    DBML
  end

  let(:input_file) do
    file = Tempfile.new(['test', '.dbml'])
    file.write(simple_dbml)
    file.close
    file
  end

  after do
    input_file.unlink
  end

  describe '#run' do
    context 'with help flag' do
      it 'displays help and exits cleanly' do
        expect do
          # Redirect stdout to avoid cluttering test output
          original_stdout = $stdout
          $stdout = StringIO.new

          # Should exit with status 0 when showing help
          expect { described_class.new(['--help']).run }.to raise_error(SystemExit) { |error|
            expect(error.status).to eq(0)
          }
        ensure
          $stdout = original_stdout
        end
      end
    end

    context 'with version flag' do
      it 'displays version and exits cleanly' do
        expect do
          # Redirect stdout
          original_stdout = $stdout
          $stdout = StringIO.new

          expect { described_class.new(['--version']).run }.to raise_error(SystemExit) { |error|
            expect(error.status).to eq(0)
          }
        ensure
          $stdout = original_stdout
        end
      end
    end

    context 'with input file' do
      it 'processes the file and outputs to stdout' do
        expect do
          # Capture stdout
          original_stdout = $stdout
          $stdout = StringIO.new

          # Should not raise an error with valid input file
          described_class.new([input_file.path]).run

          # Check that output contains expected Mermaid content
          output = $stdout.string
          expect(output).to include('erDiagram')
          expect(output).to include('users {')
        ensure
          $stdout = original_stdout
        end
      end
    end

    context 'with output file option' do
      it 'writes output to the specified file' do
        output_file = Tempfile.new(['output', '.mmd'])
        output_path = output_file.path
        output_file.close
        output_file.unlink # We just want the path

        begin
          # Redirect stdout to capture messages
          original_stdout = $stdout
          $stdout = StringIO.new

          described_class.new(['-o', output_path, input_file.path]).run

          expect(File.exist?(output_path)).to be true
          content = File.read(output_path)
          expect(content).to include('erDiagram')
          expect(content).to include('users {')
        ensure
          $stdout = original_stdout
          File.unlink(output_path) if File.exist?(output_path)
        end
      end
    end

    context 'with theme option' do
      it 'applies the specified theme' do
        expect do
          # Capture stdout
          original_stdout = $stdout
          $stdout = StringIO.new

          described_class.new(['--theme', 'dark', input_file.path]).run

          output = $stdout.string
          expect(output).to include("'theme': 'dark'")
        ensure
          $stdout = original_stdout
        end
      end
    end

    context 'with invalid file' do
      it 'displays an error message and exits with status 1' do
        expect do
          # Redirect stdout
          original_stdout = $stdout
          $stdout = StringIO.new

          expect { described_class.new(['non_existent_file.dbml']).run }.to raise_error(SystemExit) { |error|
            expect(error.status).to eq(1)
          }

          expect($stdout.string).to include('Error: File not found')
        ensure
          $stdout = original_stdout
        end
      end
    end
  end
end
