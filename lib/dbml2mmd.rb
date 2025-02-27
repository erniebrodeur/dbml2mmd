# frozen_string_literal: true

require 'dbml'
require 'slop'

require 'dbml2mmd/version'
require 'dbml2mmd/parser'
require 'dbml2mmd/converter'
require 'dbml2mmd/cli'

module Dbml2Mmd
  class Error < StandardError; end
end
