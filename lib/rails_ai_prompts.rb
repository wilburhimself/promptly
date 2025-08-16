# frozen_string_literal: true

require_relative "rails_ai_prompts/version"
require_relative "rails_ai_prompts/renderer"

module RailsAiPrompts
  class Error < StandardError; end

  def self.render(template, locals: {}, engine: :erb)
    Renderer.render(template, locals: locals, engine: engine)
  end
end

# Auto-load Railtie when inside Rails
begin
  require "rails/railtie"
  require_relative "rails_ai_prompts/railtie"
rescue LoadError
  # Rails not available; noop
end
