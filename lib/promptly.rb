# frozen_string_literal: true

require_relative "promptly/version"
require_relative "promptly/renderer"
require_relative "promptly/locator"
require_relative "promptly/cache"
require_relative "promptly/helper"

module Promptly
  class Error < StandardError; end

  def self.render_template(template, locals: {}, engine: :erb)
    Renderer.render(template, locals: locals, engine: engine)
  end

  # Configurable prompts root (defaults to Rails.root/app/prompts when Rails is present)
  def self.prompts_path
    @prompts_path || default_prompts_path
  end

  def self.prompts_path=(path)
    @prompts_path = path
  end

  # Render a template by identifier using locator rules
  # identifier: "user_onboarding/welcome"
  # locale: defaults to I18n.locale when available
  def self.render(identifier, locale: nil, locals: {}, cache: true, ttl: nil)
    if cache && Cache.enabled?
      cache_key = {
        identifier: identifier,
        locale: locale,
        locals: locals,
        prompts_path: prompts_path
      }

      Cache.fetch(cache_key, ttl: ttl) do
        render_without_cache(identifier, locale: locale, locals: locals)
      end
    else
      render_without_cache(identifier, locale: locale, locals: locals)
    end
  end

  private_class_method def self.render_without_cache(identifier, locale: nil, locals: {})
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
  require_relative "promptly/railtie"
rescue LoadError
  # Rails not available; noop
end
