## Linting Templates

Validate your prompt templates from the CLI.

```bash
# Lint all templates under the prompts path
rake ai_prompts:lint

# Lint a specific identifier (path without locale/ext)
rake ai_prompts:lint[user_onboarding/welcome_email]

# Specify locales to check for coverage
LOCALES=en,es rake ai_prompts:lint

# Require placeholders to exist in templates
REQUIRED=name,app_name rake ai_prompts:lint[user_onboarding/welcome_email]

# Point to a custom prompts directory
PROMPTS_PATH=lib/ai_prompts rake ai_prompts:lint
```

What it checks:

- **Syntax errors**
  - ERB: compiles with `ERB.new` (no execution)
  - Liquid: parses with `Liquid::Template.parse` (if `liquid` gem present)
- **Missing locale files**
  - For each identifier, warns when required locales are missing
  - Locales source: `LOCALES` env or `I18n.available_locales`
- **Required placeholders**
  - Best-effort scan for required keys from `REQUIRED` env
  - ERB: looks for `<%= ... @key ... %>` or `<%= ... key ... %>` usage
  - Liquid: looks for `{{ key }}` usage

Exit codes:

- `0` when all checks pass
- `1` when errors are found (syntax or missing required placeholders)
