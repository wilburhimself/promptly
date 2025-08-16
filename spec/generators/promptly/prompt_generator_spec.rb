# frozen_string_literal: true

require "spec_helper"
require "fileutils"
require "rails/generators"
require "generators/promptly/prompt_generator"

RSpec.describe Promptly::Generators::PromptGenerator, type: :generator do
  def in_tmp_dir
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        yield(Pathname.new(dir))
      end
    end
  end

  it "creates ERB templates for multiple locales" do
    in_tmp_dir do |dir|
      described_class.start(["user_onboarding/welcome_email", "--locales", "en", "es", "--engine", "erb"])

      expect(dir.join("app/prompts/user_onboarding/welcome_email.en.erb")).to exist
      expect(dir.join("app/prompts/user_onboarding/welcome_email.es.erb")).to exist

      en = dir.join("app/prompts/user_onboarding/welcome_email.en.erb").read
      expect(en).to include("Identifier: user_onboarding/welcome_email")
      expect(en).to include("<%= example || \"value\" %>")
    end
  end

  it "creates Liquid templates for a single locale" do
    in_tmp_dir do |dir|
      described_class.start(["ai_coaching/goal_review", "--locales", "en", "--engine", "liquid"])

      expect(dir.join("app/prompts/ai_coaching/goal_review.en.liquid")).to exist
      content = dir.join("app/prompts/ai_coaching/goal_review.en.liquid").read
      expect(content).to include("Identifier: ai_coaching/goal_review")
      expect(content).to include("{{ example | default: \"value\" }}")
    end
  end

  it "creates a fallback-only template when --no-locale is given" do
    in_tmp_dir do |dir|
      described_class.start(["content_generation/outline", "--no-locale"])

      path = dir.join("app/prompts/content_generation/outline.erb")
      expect(path).to exist
      expect(path.read).to include("Identifier: content_generation/outline")
    end
  end

  it "defaults to I18n.available_locales when locales not provided" do
    in_tmp_dir do |dir|
      if defined?(I18n)
        allow(I18n).to receive(:available_locales).and_return([:en, :fr])
      else
        stubbed = Module.new do
          def self.available_locales = [:en, :fr]
        end
        Object.const_set(:I18n, stubbed)
      end

      described_class.start(["reports/monthly_summary"])

      expect(dir.join("app/prompts/reports/monthly_summary.en.erb")).to exist
      expect(dir.join("app/prompts/reports/monthly_summary.fr.erb")).to exist

      Object.send(:remove_const, :I18n) if defined?(stubbed) && defined?(I18n) && I18n.equal?(stubbed)
    end
  end

  it "does not overwrite existing files unless --force is passed" do
    in_tmp_dir do |dir|
      args = ["user_onboarding/welcome_email", "--locales", "en", "--engine", "erb"]
      described_class.start(args)

      path = dir.join("app/prompts/user_onboarding/welcome_email.en.erb")
      original = path.read

      # Modify the file to detect overwrite
      File.write(path, original + "\nCUSTOM")

      # Run again without --force; content should remain
      described_class.start(args)
      expect(path.read).to end_with("CUSTOM")

      # Now with --force; content should be regenerated (CUSTOM removed)
      described_class.start(args + ["--force"])
      expect(path.read).not_to end_with("CUSTOM")
    end
  end
end
