# frozen_string_literal: true

require_relative "rails_ai_prompts/version"

module RailsAiPrompts
  class Error < StandardError; end
end

# Auto-load Railtie when inside Rails
begin
  require "rails/railtie"
  require_relative "rails_ai_prompts/railtie"
rescue LoadError
  # Rails not available; noop
end
