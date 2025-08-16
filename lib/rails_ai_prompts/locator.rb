# frozen_string_literal: true

module RailsAiPrompts
  class Locator
    SUPPORTED_EXTS = [".erb", ".liquid"].freeze

    def self.prompts_path
      RailsAiPrompts.prompts_path
    end

    # identifier: e.g. "user_onboarding/welcome"
    # locale: e.g. :en, :es
    # returns absolute path to template file or nil
    def self.resolve(identifier, locale: nil)
      base = File.join(prompts_path, identifier)
      locale = (locale || (defined?(I18n) ? I18n.locale : nil))&.to_s

      candidates = []
      if locale
        SUPPORTED_EXTS.each do |ext|
          candidates << "#{base}.#{locale}#{ext}"
        end
      end
      SUPPORTED_EXTS.each do |ext|
        candidates << "#{base}#{ext}"
      end

      candidates.find { |p| File.file?(p) }
    end

    # Choose engine based on file extension
    def self.engine_for(path)
      case File.extname(path)
      when ".erb" then :erb
      when ".liquid" then :liquid
      else
        :erb
      end
    end
  end
end
