# frozen_string_literal: true

module RailsAiPrompts
  class Railtie < ::Rails::Railtie
    initializer "rails_ai_prompts.configure" do
      # Intentionally minimal per DHH style; conventions over configuration
      # Hook points will be added as features land.
      Rails.logger.info("[rails_ai_prompts] loaded") if defined?(Rails.logger)
    end
  end
end
