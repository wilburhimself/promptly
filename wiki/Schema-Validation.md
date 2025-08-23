## Schema Validation

Ensure all locals passed to templates match a defined schema, so missing or mistyped variables fail fast before sending to AI.

### Schema File Next to Prompt

For each prompt, create a `schema.yml` (or `.json`) file alongside the template.

**Example:**

`app/prompts/user_onboarding/welcome_email.schema.yml`

```yml
name: string
app_name: string
user_role: string
features: array
days_since_signup: integer
```

### Validation Layer in Promptly

The validation is automatically triggered when you call `Promptly.render`. It will check for missing keys and (optionally) value types.

Supported types: `string`, `integer`, `array`.

If the validation fails, it will raise an `ArgumentError` for missing keys or a `TypeError` for mismatched types.
