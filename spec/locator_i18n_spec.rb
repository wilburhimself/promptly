# frozen_string_literal: true

require "spec_helper"
require "fileutils"
require "tmpdir"
require "i18n"

RSpec.describe RailsAiPrompts::Locator do
  around do |ex|
    Dir.mktmpdir do |dir|
      prompts_root = File.join(dir, "app", "prompts", "user_onboarding")
      FileUtils.mkdir_p(prompts_root)
      @base = File.join(dir, "app", "prompts")
      @identifier = "user_onboarding/welcome"
      RailsAiPrompts.prompts_path = @base
      ex.run
    ensure
      RailsAiPrompts.prompts_path = nil
    end
  end

  it "prefers requested locale, then default locale, then non-localized" do
    # Create default locale and unlocalized files
    File.write(File.join(@base, "user_onboarding", "welcome.en.erb"), "Hello <%= name %> (en)")
    File.write(File.join(@base, "user_onboarding", "welcome.erb"), "Hello <%= name %> (fallback)")

    I18n.available_locales = [:en, :es]
    I18n.locale = :es
    I18n.default_locale = :en

    path = described_class.resolve(@identifier, locale: :es)
    expect(path).to end_with("welcome.es.erb").or end_with("welcome.en.erb").or end_with("welcome.erb")

    # Since requested :es does not exist, it should fall back to default :en
    expect(path).to end_with("welcome.en.erb")

    # Remove default, expect fallback to non-localized
    FileUtils.rm_f(File.join(@base, "user_onboarding", "welcome.en.erb"))
    path2 = described_class.resolve(@identifier, locale: :es)
    expect(path2).to end_with("welcome.erb")
  end

  it "uses requested locale when present" do
    File.write(File.join(@base, "user_onboarding", "welcome.es.erb"), "Hola <%= name %>")
    I18n.locale = :en
    I18n.default_locale = :en

    path = described_class.resolve(@identifier, locale: :es)
    expect(path).to end_with("welcome.es.erb")
  end
end
