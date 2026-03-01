# frozen_string_literal: true

require_relative "promptly/version"
require_relative "promptly/renderer"
require_relative "promptly/locator"
require_relative "promptly/cache"
require_relative "promptly/helper"
require_relative "promptly/validator"
require "yaml"

module Promptly
  class Error < StandardError; end
  class ValidationError < Error; end

  class Prompt
    attr_reader :content, :version, :author, :change_notes

    def initialize(content:, version: nil, author: nil, change_notes: nil)
      @content = content
      @version = version
      @author = author
      @change_notes = change_notes
    end

    def to_s
      content
    end
  end

  def self.render_template(template, locals: {}, engine: :erb)
    Renderer.render(template, locals: locals, engine: engine)
  end

  def self.response_format(identifier, strict: true)
    schema_path = File.join(prompts_path, "#{identifier}.response.json")
    raise Error, "Schema file not found for '#{identifier}' at #{schema_path}" unless File.exist?(schema_path)

    require "json"
    schema_content = JSON.parse(File.read(schema_path))

    {
      type: "json_schema",
      json_schema: {
        name: identifier.gsub(/[^a-zA-Z0-9_-]/, "_"),
        strict: strict,
        schema: schema_content
      }
    }
  end

  def self.validate_response!(identifier, json_string)
    schema_path = File.join(prompts_path, "#{identifier}.response.json")
    raise Error, "Schema file not found for '#{identifier}' at #{schema_path}" unless File.exist?(schema_path)

    require "json"
    require "json_schemer"

    schema_content = JSON.parse(File.read(schema_path))
    parsed_json = JSON.parse(json_string)

    schemer = JSONSchemer.schema(schema_content)
    unless schemer.valid?(parsed_json)
      errors = schemer.validate(parsed_json).to_a
      raise ValidationError, "Response does not match schema: #{errors.inspect}"
    end

    parsed_json
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
    schema_path = File.join(prompts_path, "#{identifier}.schema.yml")
    Validator.validate!(locals, schema_path)

    path = Locator.resolve(identifier, locale: locale)
    raise Error, "Template not found for '#{identifier}' (locale: #{locale.inspect}) under #{prompts_path}" unless path

    engine = Locator.engine_for(path)
    file_content = File.read(path)

    # Extract YAML front matter
    match = file_content.match(/\A---\n(.*)
---\s*\n/m)
    if match
      metadata = YAML.safe_load(match[1])
      template = match.post_match
    else
      metadata = {}
      template = file_content
    end

    content = Renderer.render(template, locals: locals, engine: engine)

    Prompt.new(
      content: content,
      version: metadata["version"],
      author: metadata["author"],
      change_notes: metadata["change_notes"]
    )
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
