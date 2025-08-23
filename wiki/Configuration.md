## Configuration

### Custom Prompts Path

```ruby
# config/initializers/rails_ai_prompts.rb
Promptly.prompts_path = Rails.root.join("lib", "ai_prompts")
```

### Caching

Promptly supports optional caching for rendered prompts.

- Default: enabled, TTL = 3600 seconds (1 hour).
- In Rails, the Railtie auto-uses `Rails.cache` if present.

Configure globally:

```ruby
# config/initializers/promptly.rb
Promptly::Cache.configure do |c|
  c.store = Rails.cache # or any ActiveSupport::Cache store
  c.ttl = 3600          # default TTL in seconds
  c.enabled = true      # globally enable/disable caching
end
```

Per-call options:

```ruby
# Bypass cache for this render only
Promptly.render("user_onboarding/welcome_email", locals: {...}, cache: false)

# Custom TTL for this render only
Promptly.render("user_onboarding/welcome_email", locals: {...}, ttl: 5.minutes)
```

Invalidation:

```ruby
# Clear entire cache store (if supported by the store)
Promptly::Cache.clear

# Delete a specific cached entry
Promptly::Cache.delete(
  identifier: "user_onboarding/welcome_email",
  locale: :en,
  locals: {name: "John"},
  prompts_path: Promptly.prompts_path
)
```

### Direct Template Rendering

```ruby
# Render ERB directly (without file lookup)
template = "Hello <%= name %>, welcome to <%= app %>!"
output = Promptly.render_template(template, locals: {name: "John", app: "MyApp"})

# Render Liquid directly
template = "Hello {{ name }}, welcome to {{ app }}!"
output = Promptly.render_template(template, locals: {name: "John", app: "MyApp"}, engine: :liquid)
```
