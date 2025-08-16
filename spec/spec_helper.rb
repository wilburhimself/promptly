# frozen_string_literal: true

require "bundler/setup"
require "rails_ai_prompts"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = :random
  Kernel.srand config.seed
end
