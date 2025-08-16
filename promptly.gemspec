# frozen_string_literal: true

require_relative "lib/promptly/version"

Gem::Specification.new do |spec|
  spec.name = "promptly"
  spec.version = Promptly::VERSION
  spec.authors = ["Wilbur Suero"]
  spec.email = ["wilbur@example.com"]

  spec.summary = "Opinionated Rails integration for reusable AI prompt templates"
  spec.description = "Build maintainable, localized, and testable AI prompts using ERB or Liquid templates with Rails conventions"
  spec.homepage = "https://github.com/wilburhimself/promptly"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/wilburhimself/promptly"
  spec.metadata["changelog_uri"] = "https://github.com/wilburhimself/promptly/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://github.com/wilburhimself/promptly/blob/main/README.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemfiles = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.files = gemfiles

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "actionview", "~> 7.0"

  # Development dependencies
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "standard", "~> 1.37"
  spec.add_development_dependency "liquid", "~> 5.5"
  spec.add_development_dependency "railties", "~> 7.0"
end
