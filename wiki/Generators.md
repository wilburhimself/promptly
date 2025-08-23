## Generators

Create prompt templates following conventions.

```bash
# ERB with multiple locales
rails g promptly:prompt user_onboarding/welcome_email --locales en es --engine erb

# Liquid with a single locale
rails g promptly:prompt ai_coaching/goal_review --locales en --engine liquid

# Fallback-only (no locale suffix)
rails g promptly:prompt content_generation/outline --no-locale
```

Options:

- `--engine` erb|liquid (default: erb)
- `--locales` space-separated list (default: I18n.available_locales if available, else `en`)
- `--no-locale` create only fallback file (e.g., `welcome_email.erb`)
- `--force` overwrite existing files

Generated files are placed under `app/prompts/` and directories are created as needed.

Examples:

- `app/prompts/user_onboarding/welcome_email.en.erb`
- `app/prompts/user_onboarding/welcome_email.es.erb`
- `app/prompts/ai_coaching/goal_review.en.liquid`
- `app/prompts/content_generation/outline.erb` (fallback-only)

The generator seeds a minimal, intention-revealing scaffold you can edit immediately.
