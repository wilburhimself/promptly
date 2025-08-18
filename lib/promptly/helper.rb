# frozen_string_literal: true

module Promptly
  module Helper
    # Render a prompt template by identifier.
    #
    # Example:
    #   # app/prompts/welcome_email.erb
    #   # Hello <%= @user.name %>, welcome!
    #
    #   # In a mailer, job, or service including this module:
    #   # render_prompt("welcome_email", user: @user)
    #
    # Supports locale-aware lookup and caching.
    def render_prompt(identifier, locale: nil, cache: true, ttl: nil, **locals)
      Promptly.render(identifier, locale: locale, locals: locals, cache: cache, ttl: ttl)
    end
  end
end
