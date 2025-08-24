# Welcome to the Promptly Wiki!

Promptly is an opinionated Rails integration for reusable AI prompt templates. It helps you build maintainable, localized, and testable AI prompts using ERB or Liquid templates with Rails conventions.

This wiki provides detailed documentation for Promptly. If you are new to Promptly, we recommend starting with the [Quick Start](https://github.com/wilburhimself/promptly/wiki/Quick-Start) guide.

## Features

- **Template rendering**: ERB (via ActionView) and optional Liquid support
- **I18n integration**: Automatic locale fallback (`welcome.es.erb` → `welcome.en.erb` → `welcome.erb`)
- **Rails conventions**: Store prompts in `app/prompts/` with organized subdirectories
- **Render & CLI**: Test prompts in Rails console or via rake tasks
- **Minimal setup**: Auto-loads via Railtie, zero configuration required
- **Prompt caching**: Configurable cache store, TTL, and cache-bypass options
- **Schema Validation**: Ensure all locals passed to templates match a defined schema.
- **Functional Prompt Tests**: Write functional tests for your prompts using RSpec.

## Documentation

- [Quick Start](https://github.com/wilburhimself/promptly/wiki/Quick-Start)
- [Schema Validation](https://github.com/wilburhimself/promptly/wiki/Schema-Validation)
- [Helper: render_prompt](https://github.com/wilburhimself/promptly/wiki/Helper-render_prompt)
- [Rails App Integration](https://github.com/wilburhimself/promptly/wiki/Rails-App-Integration)
- [I18n Prompts Usage](https://github.com/wilburhimself/promptly/wiki/I18n-Prompts-Usage)
- [Liquid Templates](https://github.com/wilburhimself/promptly/wiki/Liquid-Templates)
- [Configuration](https://github.com/wilburhimself/promptly/wiki/Configuration)
- [Generators](https://github.com/wilburhimself/promptly/wiki/Generators)
- [Linting Templates](https://github.com/wilburhimself/promptly/wiki/Linting-Templates)
- [Functional Prompt Tests](https://github.com/wilburhimself/promptly/wiki/Functional-Prompt-Tests)
