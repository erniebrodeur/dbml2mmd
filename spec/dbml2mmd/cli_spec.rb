# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dbml2Mmd::CLI do
  subject(:cli) { described_class.new(args) }

  let(:simple_dbml) do
    <<~DBML
      Table users {
        id integer [primary key]
        username varchar
      }
    DBML
  end

  let(:args) { ['input.dbml'] }

  # Create more realistic Slop mocks
  let(:slop_options) { instance_double(Slop::Options) }
  let(:slop_result) { instance_double(Slop::Result) }

  before do
    # Setup Slop mocking
    allow(Slop::Options).to receive(:new).and_return(slop_options)
    allow(slop_options).to receive(:banner=)
    allow(slop_options).to receive(:separator)
    allow(slop_options).to receive(:on)
    allow(slop_options).to receive(:to_s).and_return('Usage help text')
    allow(slop_options).to receive(:parse).and_return(slop_result)

    # Default behavior for slop result
    allow(slop_result).to receive(:args).and_return(args)
    allow(slop_result).to receive(:[]).with(any_args).and_return(nil)

    # Setup file mocks
    allow(File).to receive(:read).and_return(simple_dbml)
    allow(File).to receive(:write)
    allow(File).to receive(:exist?).and_return(true)
  end

  describe '#run' do
    context 'when --help flag is provided' do
      before do
        allow(slop_result).to receive(:[]).with(:help).and_return(true)
      end

      it 'displays the help message' do
        expect { cli.run }.to output(/Usage help text/).to_stdout.and raise_error(SystemExit)
      end

      it 'exits with status code 0' do
        expect { cli.run }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(0)
        end
      end
    end

    context 'when --version flag is provided' do
      before do
        allow(slop_result).to receive(:[]).with(:help).and_return(false)
        allow(slop_result).to receive(:[]).with(:version).and.return(true)
      end

      it 'displays the version' do
        expect { cli.run }.to output(/\d+\.\d+\.\d+/).to_stdout
      end

      it 'exits with status code 0' do
        expect { cli.run }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(0)
        end
      end
    end

    context 'when processing an input file' do
      before do
        allow(slop_result).to receive(:[]).with(:help).and.return(false)
        allow(slop_result).to receive(:[]).with(:version).and.return(false)
      end

      it 'generates mermaid diagram syntax' do
        expect { cli.run }.to output(/erDiagram.*users {/m).to_stdout
      end
    end

    context 'when output file option is provided' do
      before do
        allow(slop_result).to receive(:[]).with(:help).and.return(false)
        allow(slop_result).to receive(:[]).with(:version).and.return(false)
        allow(slop_result).to receive(:[]).with(:output).and.return('output.mmd')
      end

      it 'writes output to the specified file' do
        expect(File).to receive(:write).with('output.mmd', /erDiagram.*users {/m)
        cli.run
      end
    end

    context 'when theme option is provided' do
      before do
        allow(slop_result).to receive(:[]).with(:help).and.return(false)
        allow(slop_result).to receive(:[]).with(:version).and.return(false)
        allow(slop_result).to receive(:[]).with(:theme).and.return('dark')
      end

      it 'applies the specified theme' do
        expect { cli.run }.to output(/"theme": "dark"/).to_stdout
      end
    end

    context 'when an invalid file is provided' do
      before do
        allow(slop_result).to receive(:[]).with(:help).and.return(false)
        allow(slop_result).to receive(:[]).with(:version).and.return(false)
        allow(slop_result).to receive(:args).and.return(['non_existent.dbml'])
        allow(File).to receive(:exist?).with('non_existent.dbml').and.return(false)
      end

      it 'displays an error message and exits with status 1' do
        expect { cli.run }.to output(/Error: File not found/).to_stdout.and raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end
      end
    end
  end
end
