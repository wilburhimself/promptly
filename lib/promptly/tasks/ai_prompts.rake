# frozen_string_literal: true

namespace :ai_prompts do
  desc "Render a prompt: rake ai_prompts:render[identifier,locale]"
  task :render, [:identifier, :locale] => :environment do |_, args|
    identifier = args[:identifier]
    locale = args[:locale]
    prompts_path = ENV["PROMPTS_PATH"]

    unless identifier
      warn "Usage: rake ai_prompts:render[identifier,locale]"
      exit 1
    end

    begin
      Promptly.prompts_path = prompts_path if prompts_path

      output = Promptly.render(identifier, locale: locale)
      puts output
    rescue Promptly::Error => e
      warn "Error: #{e.class}: #{e.message}"
      exit 1
    end
  end
end
