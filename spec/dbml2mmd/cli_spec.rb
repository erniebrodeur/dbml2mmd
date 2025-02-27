# frozen_string_literal: true

require 'spec_helper'
require 'dbml2mmd/cli'
require 'stringio'

RSpec.describe Dbml2Mmd::CLI do
  let(:output) { StringIO.new }
  let(:error_output) { StringIO.new }
  let(:args) { [] }
  let(:exit_code) { subject.run }

  subject { described_class.new(args, output: output, error_output: error_output) }

  describe '#run' do
    context 'with --help flag' do
      let(:args) { ['--help'] }

      it 'displays help information' do
        exit_code
        expect(output.string).to include('Usage: dbml2mmd [options] [input_file]')
      end

      it 'exits with code 0' do
        expect(exit_code).to eq(0)
      end

      it 'sets exit_requested flag' do
        exit_code
        expect(subject.exit_requested?).to be true
      end
    end

    context 'with --version flag' do
      let(:args) { ['--version'] }

      it 'displays version information' do
        exit_code
        expect(output.string).to include('DBML to Mermaid Converter v')
      end

      it 'exits with code 0' do
        expect(exit_code).to eq(0)
      end
    end

    context 'with invalid options' do
      let(:args) { ['--invalid-option'] }

      it 'displays error message' do
        exit_code
        expect(error_output.string).to include('Error:')
      end

      it 'exits with code 1' do
        expect(exit_code).to eq(1)
      end
    end
  end

  describe 'input processing' do
    let(:converter) do
      instance_double(Dbml2Mmd::Converter, convert: 'mermaid output', output_html: '<html>content</html>')
    end
    let(:dbml_content) { 'Table users { id integer }' }

    before do
      allow(subject).to receive(:create_converter).and_return(converter)
    end

    context 'when reading from a file' do
      let(:args) { ['input.dbml'] }

      before do
        allow(File).to receive(:read).with('input.dbml').and_return(dbml_content)
      end

      it 'reads the file content' do
        exit_code
        expect(output.string).to include('mermaid output')
      end

      context 'when file does not exist' do
        before do
          allow(File).to receive(:read).and_raise(Errno::ENOENT.new('File not found'))
        end

        it 'displays error message' do
          exit_code
          expect(error_output.string).to include('File not found')
        end

        it 'exits with code 1' do
          expect(exit_code).to eq(1)
        end
      end
    end

    context 'when output is specified' do
      let(:args) { ['--output', 'output.mmd', 'input.dbml'] }

      before do
        allow(File).to receive(:read).with('input.dbml').and_return(dbml_content)
        allow(File).to receive(:write).and_return(true)
      end

      it 'writes output to the specified file' do
        expect(File).to receive(:write).with('output.mmd', 'mermaid output')
        exit_code
      end

      it 'confirms output was written' do
        exit_code
        expect(output.string).to include('Output written to output.mmd')
      end
    end

    context 'with --html flag' do
      let(:args) { ['--html', '--output', 'output.html', 'input.dbml'] }

      before do
        allow(File).to receive(:read).with('input.dbml').and_return(dbml_content)
        allow(File).to receive(:write).and_return(true)
      end

      it 'creates options with html_output: true' do
        exit_code
        expect(subject.options[:html_output]).to be true
      end

      it 'writes HTML output to the specified file' do
        expect(File).to receive(:write).with('output.html', '<html>content</html>')
        exit_code
      end
    end
  end

  describe 'with verbose flag' do
    let(:args) { ['--verbose', 'input.dbml'] }
    let(:dbml_content) { 'Table users { id integer }' }

    before do
      allow(File).to receive(:read).with('input.dbml').and_return(dbml_content)
      allow(subject).to receive(:create_converter).and_return(
        instance_double(Dbml2Mmd::Converter, convert: 'mermaid output')
      )
    end

    it 'outputs verbose information' do
      exit_code
      expect(output.string).to include('Input source:')
      expect(output.string).to include('Theme:')
      expect(output.string).to include('HTML output:')
      expect(output.string).to include('Filtering tables:')
    end
  end

  describe 'with theme option' do
    let(:args) { ['--theme', 'dark', 'input.dbml'] }
    let(:dbml_content) { 'Table users { id integer }' }

    before do
      allow(File).to receive(:read).with('input.dbml').and_return(dbml_content)
    end

    it 'sets the theme in options' do
      exit_code
      expect(subject.options[:theme]).to eq('dark')
    end

    it 'passes options to the converter' do
      expect(Dbml2Mmd::Converter).to receive(:new).with(hash_including(theme: 'dark')).and_return(
        instance_double(Dbml2Mmd::Converter, convert: 'mermaid output')
      )
      exit_code
    end
  end

  describe 'with only option' do
    let(:args) { ['--only', 'users,posts', 'input.dbml'] }
    let(:dbml_content) { 'Table users { id integer }' }

    before do
      allow(File).to receive(:read).with('input.dbml').and_return(dbml_content)
    end

    it 'sets the only_tables in options' do
      exit_code
      expect(subject.options[:only_tables]).to eq('users,posts')
    end

    it 'passes options to the converter' do
      expect(Dbml2Mmd::Converter).to receive(:new).with(hash_including(only_tables: 'users,posts')).and_return(
        instance_double(Dbml2Mmd::Converter, convert: 'mermaid output')
      )
      exit_code
    end
  end

  describe 'error handling' do
    context 'when converter raises an error' do
      let(:args) { ['input.dbml'] }

      before do
        allow(File).to receive(:read).with('input.dbml').and_return('invalid dbml')
        allow_any_instance_of(Dbml2Mmd::Converter).to receive(:convert).and_raise(StandardError.new('Parsing error'))
      end

      it 'displays the error message' do
        exit_code
        expect(error_output.string).to include('Error: Parsing error')
      end

      it 'exits with code 1' do
        expect(exit_code).to eq(1)
      end

      context 'with verbose flag' do
        let(:args) { ['--verbose', 'input.dbml'] }

        it 'includes backtrace in the error output' do
          exit_code
          # Can't test exact backtrace content, but should have multiple lines
          expect(error_output.string.lines.count).to be > 1
        end
      end
    end
  end
end
