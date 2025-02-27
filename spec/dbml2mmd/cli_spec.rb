# frozen_string_literal: true

require "spec_helper"
# We'll load the CLI script or a method that runs the CLI with arguments.
# It's typically in exe/dbml2mmd, so we might test that indirectly.

RSpec.describe "dbml2mmd CLI", type: :cli do
  it "prints help when invoked with --help" do
    skip "TODO: Implement CLI testing (e.g., Open3.capture3)"
  end
end
