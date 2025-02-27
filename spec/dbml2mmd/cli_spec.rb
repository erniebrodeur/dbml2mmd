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

  let(:mock_parser) { instance_double(Slop::Options) }
  let(:mock_opts) { instance_double(Slop::Result) }
  let(:args) { ['input.dbml'] }

  before do
    allow(Slop::Options).to receive(:new).and_return(mock_parser)
    allow(mock_parser).to receive(:banner=)
    allow(mock_parser).to receive(:on)
    allow(mock_parser).to receive(:parse).and_return(mock_opts)
    allow(File).to receive(:read).and_return(simple_dbml)
    allow(File).to receive(:write)
    allow(File).to receive(:exist?).and_return(true)
  end

  describe '#run' do
    context 'when --help flag is provided' do
      let(:args) { ['--help'] }

      before do
        allow(mock_opts).to receive(:help).and_return(true)
        allow(mock_parser).to receive(:to_s).and_return('Usage help')
      end

      it 'displays the help message' do
        expect { cli.run }.to output(/Usage help/).to_stdout.and raise_error(SystemExit)
      end

      it 'exits with status code 0' do
        expect { cli.run }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(0)
        end
      end
    end

    context 'when --version flag is provided' do
      let(:args) { ['--version'] }

      before do
        allow(mock_opts).to receive(:help).and_return(false)
        allow(mock_opts).to receive(:version).and_return(true)
      end

      it 'displays the version' do
        expect { cli.run }.to output(/\d+\.\d+\.\d+/).to_stdout
      end

      it 'exits with status code 0' do
        expect { cli.run }.to raise_error(SystemExit) { |error|
          expect(error.status).to eq(0)
        }
      end
    end

    context 'when processing an input file' do
      before do
        allow(mock_opts).to receive(:help).and_return(false)
        allow(mock_opts).to receive(:version).and_return(false)
        allow(mock_opts).to receive(:[]).with(:output).and_return(nil)
        allow(mock_opts).to receive(:[]).with(:theme).and_return(nil)
        allow(mock_opts).to receive(:args).and_return(args)
      end

      it 'generates mermaid diagram syntax' do
        expect { cli.run }.to output(/erDiagram.*users {/m).to_stdout
      end
    end

    context 'when output file option is provided' do
      let(:args) { ['-o', 'output.mmd', 'input.dbml'] }

      before do
        allow(mock_opts).to receive(:help).and_return(false)
        allow(mock_opts).to receive(:version).and_return(false)
        allow(mock_opts).to receive(:[]).with(:output).and_return('output.mmd')
        allow(mock_opts).to receive(:[]).with(:theme).and_return(nil)
        allow(mock_opts).to receive(:args).and_return(args)
      end

      it 'writes output to the specified file' do
        expect(File).to receive(:write).with('output.mmd', /erDiagram.*users {/m)
        expect { cli.run }.to output.to_stdout
      end
    end

    context 'when theme option is provided' do
      let(:args) { ['--theme', 'dark', 'input.dbml'] }

      before do
        allow(mock_opts).to receive(:help).and_return(false)
        allow(mock_opts).to receive(:version).and_return(false)
        allow(mock_opts).to receive(:[]).with(:output).and_return(nil)
        allow(mock_opts).to receive(:[]).with(:theme).and_return('dark')
        allow(mock_opts).to receive(:args).and_return(args)
      end

      it 'applies the specified theme' do
        expect { cli.run }.to output(/"theme": "dark"/).to_stdout
      end
    end

    context 'when an invalid file is provided' do
      let(:args) { ['non_existent.dbml'] }

      before do
        allow(mock_opts).to receive(:help).and_return(false)
        allow(mock_opts).to receive(:version).and_return(false)
        allow(mock_opts).to receive(:[]).with(:output).and_return(nil)
        allow(mock_opts).to receive(:[]).with(:theme).and_return(nil)
        allow(mock_opts).to receive(:args).and_return(['non_existent.dbml'])
        allow(File).to receive(:exist?).with('non_existent.dbml').and_return(false)
      end

      it 'displays an error message and exits with status 1' do
        expect { cli.run }.to output(/Error: File not found/).to_stdout.and raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end
      end
    end
  end
end
