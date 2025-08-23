# Promptly

Opinionated Rails integration for reusable AI prompt templates. Build maintainable, localized, and testable AI prompts using ERB or Liquid templates with Rails conventions.

## Features

- **Template rendering**: ERB (via ActionView) and optional Liquid support
- **I18n integration**: Automatic locale fallback (`welcome.es.erb` → `welcome.en.erb` → `welcome.erb`)
- **Rails conventions**: Store prompts in `app/prompts/` with organized subdirectories
- **Render & CLI**: Test prompts in Rails console or via rake tasks
- **Minimal setup**: Auto-loads via Railtie, zero configuration required
- **Prompt caching**: Configurable cache store, TTL, and cache-bypass options
- **Schema Validation**: Ensure all locals passed to templates match a defined schema.

## Documentation

For detailed documentation, please visit the [Promptly Wiki](https://github.com/wilburhimself/promptly/wiki).

## Install

Add to your Gemfile:

```ruby
gem "promptly"
```

For Liquid template support, also add:

```ruby
gem "liquid"
```

Then run:

```bash
bundle install
```

## Quick Start

```ruby
# In a controller, service, or anywhere in Rails
prompt = Promptly.render(
  "user_onboarding/welcome_email",
  locale: :es,
  locals: {
    name: "María García",
    app_name: "ProjectHub",
    user_role: "Team Lead",
    features: ["Create projects", "Invite team members", "Track progress", "Generate reports"],
    days_since_signup: 2
  }
)

# Send to your AI service (OpenAI, Anthropic, etc.)
ai_response = openai_client.completions(
  model: "gpt-4",
  messages: [{role: "user", content: prompt}]
)

puts ai_response.dig("choices", 0, "message", "content")
# => AI-generated personalized welcome email in Spanish
```

## Development

```bash
# Install dependencies
bundle install

# Run tests
bundle exec rspec

# Run linter
bundle exec standardrb

# Build gem
rake build
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

MIT