# frozen_string_literal: true

require "bundler/setup"
require "promptly"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Use deterministic order to avoid load-order issues
  config.order = :defined
end
