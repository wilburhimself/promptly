# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "rails_ai_prompts"
  spec.version = File.read(File.expand_path("lib/rails_ai_prompts/version.rb", __dir__)).match(/VERSION\s*=\s*"([^"]+)"/)[1]
  spec.authors = ["Wilbur Suero"]
  spec.email = ["suerowilbur@gmail.com"]

  spec.summary = "Rails integration for reusable AI prompt templates"
  spec.description = "Opinionated, lightweight Rails integration for composing, validating, and reusing AI prompt templates."
  spec.homepage = "https://github.com/wilburhimself/rails_ai_prompts"
  spec.license = "MIT"

  spec.files = Dir.glob("{lib}/**/*") + %w[README.md LICENSE]
  spec.require_paths = ["lib"]

  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage,
    "changelog_uri" => "#{spec.homepage}/releases"
  }

  spec.add_dependency "rails", ">= 6.1"

  spec.add_development_dependency "rake", ">= 13.0"
  spec.add_development_dependency "standard", ">= 1.37"
end
