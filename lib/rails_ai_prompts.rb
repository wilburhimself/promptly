# frozen_string_literal: true

require_relative "rails_ai_prompts/version"
require_relative "rails_ai_prompts/renderer"
require_relative "rails_ai_prompts/locator"

module RailsAiPrompts
  class Error < StandardError; end

  def self.render(template, locals: {}, engine: :erb)
    Renderer.render(template, locals: locals, engine: engine)
  end

  # Configurable prompts root (defaults to Rails.root/app/prompts when Rails is present)
  def self.prompts_path
    @prompts_path || default_prompts_path
  end

  def self.prompts_path=(path)
    @prompts_path = path
  end

  # Preview a template by identifier using locator rules
  # identifier: "user_onboarding/welcome"
  # locale: defaults to I18n.locale when available
  def self.preview(identifier, locale: nil, locals: {})
    path = Locator.resolve(identifier, locale: locale)
    raise Error, "Template not found for '#{identifier}' (locale: #{locale.inspect}) under #{prompts_path}" unless path

    engine = Locator.engine_for(path)
    template = File.read(path)
    Renderer.render(template, locals: locals, engine: engine)
  end

  def self.default_prompts_path
    if defined?(::Rails) && Rails.respond_to?(:root) && Rails.root
      File.join(Rails.root.to_s, "app", "prompts")
    else
      File.expand_path("app/prompts", Dir.pwd)
    end
  end
end

# Auto-load Railtie when inside Rails
begin
  require "rails/railtie"
  require_relative "rails_ai_prompts/railtie"
rescue LoadError
  # Rails not available; noop
end
