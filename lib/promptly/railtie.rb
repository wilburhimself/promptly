# frozen_string_literal: true

module Promptly
  class Railtie < Rails::Railtie
    initializer "promptly.configure" do
      # Intentionally minimal per DHH style; conventions over configuration
      # Hook points will be added as features land.
      Rails.logger.info("[promptly] loaded") if defined?(Rails.logger)

      # Auto-configure Rails cache if available
      if defined?(Rails.cache)
        Promptly::Cache.store = Rails.cache
      end
    end

    rake_tasks do
      load "promptly/tasks/ai_prompts.rake"
    end
  end
end
