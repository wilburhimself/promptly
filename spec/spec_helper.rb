# frozen_string_literal: true

require "bundler/setup"
require "logger"
require "promptly"
require_relative "support/prompt_helper"

RSpec.configure do |config|
  config.include PromptHelper
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Use deterministic order to avoid load-order issues
  config.order = :defined
end
