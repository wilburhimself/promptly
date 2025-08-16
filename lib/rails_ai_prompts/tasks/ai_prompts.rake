# frozen_string_literal: true

namespace :ai_prompts do
  desc "Preview a prompt: rake ai_prompts:preview[identifier,locale]"
  task :preview, [:identifier, :locale] => :environment do |_, args|
    identifier = args[:identifier]
    locale = args[:locale]

    unless identifier
      warn "Usage: rake ai_prompts:preview[identifier,locale]"
      exit 1
    end

    begin
      output = RailsAiPrompts.preview(identifier, locale: locale)
      puts output
    rescue => e
      warn "Error: #{e.class}: #{e.message}"
      exit 1
    end
  end
end
