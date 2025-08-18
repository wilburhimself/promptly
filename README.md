
# Promptly

Opinionated Rails integration for reusable AI prompt templates. Build maintainable, localized, and testable AI prompts using ERB or Liquid templates with Rails conventions.

## Features

- **Template rendering**: ERB (via ActionView) and optional Liquid support
- **I18n integration**: Automatic locale fallback (`welcome.es.erb` → `welcome.en.erb` → `welcome.erb`)
- **Rails conventions**: Store prompts in `app/prompts/` with organized subdirectories
- **Render & CLI**: Test prompts in Rails console or via rake tasks
- **Minimal setup**: Auto-loads via Railtie, zero configuration required
- **Prompt caching**: Configurable cache store, TTL, and cache-bypass options

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

### 1. Create prompt templates

Create `app/prompts/user_onboarding/welcome_email.en.erb`:

```erb
You are a friendly customer success manager writing a personalized welcome email.

Context:
- User name: <%= name %>
- App name: <%= app_name %>
- User's role: <%= user_role %>
- Available features for this user: <%= features.join(", ") %>
- User signed up <%= days_since_signup %> days ago

Task: Write a warm, personalized welcome email that:
1. Addresses the user by name
2. Explains the key benefits specific to their role
3. Highlights 2-3 most relevant features they should try first
4. Includes a clear call-to-action to get started
5. Maintains a professional but friendly tone

Keep the email concise (under 200 words) and actionable.
```

Create `app/prompts/user_onboarding/welcome_email.es.erb`:

```erb
Eres un gerente de éxito del cliente amigable escribiendo un email de bienvenida personalizado.

Contexto:
- Nombre del usuario: <%= name %>
- Nombre de la app: <%= app_name %>
- Rol del usuario: <%= user_role %>
- Funciones disponibles para este usuario: <%= features.join(", ") %>
- El usuario se registró hace <%= days_since_signup %> días

Tarea: Escribe un email de bienvenida cálido y personalizado que:
1. Se dirija al usuario por su nombre
2. Explique los beneficios clave específicos para su rol
3. Destaque 2-3 funciones más relevantes que debería probar primero
4. Incluya una llamada a la acción clara para comenzar
5. Mantenga un tono profesional pero amigable

Mantén el email conciso (menos de 200 palabras) y orientado a la acción.
```

### 2. Render in your Rails app

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

### 3. Test via Rails console

```ruby
rails console

# Render the prompt before sending to AI
prompt = Promptly.render(
  "user_onboarding/welcome_email", 
  locale: :en, 
  locals: {
    name: "John Smith", 
    app_name: "ProjectHub", 
    user_role: "Developer",
    features: ["API access", "Code reviews", "Deployment tools"],
    days_since_signup: 1
  }
)
puts prompt

# Uses I18n.locale by default
I18n.locale = :es
prompt = Promptly.render(
  "user_onboarding/welcome_email", 
  locals: {
    name: "María García", 
    app_name: "ProjectHub",
    user_role: "Team Lead",
    features: ["Crear proyectos", "Invitar miembros", "Seguimiento"],
    days_since_signup: 3
  }
)
```

### 4. CLI rendering

```bash
# Render specific locale (shows the prompt, not AI output)
rails ai_prompts:render[user_onboarding/welcome_email,es]

# Uses default locale
rails ai_prompts:render[user_onboarding/welcome_email]
```

## Helper: render_prompt

Use a concise helper anywhere in Rails to render prompts with locals that are also exposed as instance variables inside ERB templates.

* **Auto-included**: Controllers, Mailers, and Jobs via Railtie.
* **Services/Plain Ruby**: `include Promptly::Helper`.

Example template and usage:

```erb
# app/prompts/welcome_email.erb
Hello <%= @user.name %>, welcome to our service!
We're excited to have you join.
```

```ruby
# In a mailer, job, controller, or a service that includes Promptly::Helper
rendered = render_prompt("welcome_email", user: @user)
```

Notes:

- **Locals become @instance variables** in ERB. Passing `user: @user` makes `@user` available in the template.
- **Localization**: `render_prompt("welcome_email", locale: :es, user: user)` resolves `welcome_email.es.erb` with fallback per `Promptly::Locator`.
- **Caching**: Controlled per call (`cache:`, `ttl:`) and globally via `Promptly::Cache`.

## Rails App Integration

### Service Object Pattern

```ruby
# app/services/ai_prompt_service.rb
class AiPromptService
  def self.generate_welcome_email(user, locale: I18n.locale)
    prompt = Promptly.render(
      "user_onboarding/welcome_email",
      locale: locale,
      locals: {
        name: user.full_name,
        app_name: Rails.application.class.module_parent_name,
        user_role: user.role.humanize,
        features: available_features_for(user),
        days_since_signup: (Date.current - user.created_at.to_date).to_i
      }
    )
    
    # Send to AI service and return generated content
    openai_client.chat(
      model: "gpt-4",
      messages: [{role: "user", content: prompt}]
    ).dig("choices", 0, "message", "content")
  end

  private

  def self.available_features_for(user)
    # Return features based on user's plan, role, etc.
    case user.plan
    when "basic"
      ["Create projects", "Basic reporting"]
    when "pro"
      ["Create projects", "Team collaboration", "Advanced analytics", "API access"]
    else
      ["Create projects"]
    end
  end

  def self.openai_client
    @openai_client ||= OpenAI::Client.new(access_token: Rails.application.credentials.openai_api_key)
  end
end
```

### Mailer Integration

```ruby
# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    @ai_content = AiPromptService.generate_welcome_email(user, locale: user.locale)
    
    mail(
      to: user.email,
      subject: t('mailer.welcome.subject')
    )
  end
end
```

### Background Job Usage

```ruby
# app/jobs/generate_ai_content_job.rb
class GenerateAiContentJob < ApplicationJob
  def perform(user_id, prompt_identifier, locals = {})
    user = User.find(user_id)
    
    prompt = Promptly.render(
      prompt_identifier,
      locale: user.locale,
      locals: locals.merge(
        user_name: user.full_name,
        user_role: user.role,
        account_type: user.account_type
      )
    )
    
    # Generate AI content
    ai_response = openai_client.chat(
      model: "gpt-4",
      messages: [{role: "user", content: prompt}]
    )
    
    generated_content = ai_response.dig("choices", 0, "message", "content")
    
    # Store or send the generated content
    user.notifications.create!(
      title: "AI Generated Content Ready",
      content: generated_content,
      notification_type: prompt_identifier.split('/').last
    )
  end

  private

  def openai_client
    @openai_client ||= OpenAI::Client.new(access_token: Rails.application.credentials.openai_api_key)
  end
end

# Usage
GenerateAiContentJob.perform_later(
  user.id,
  "coaching/goal_review",
  {
    current_goals: user.goals.active.pluck(:title),
    progress_summary: "Made good progress on fitness goals",
    challenges: ["Time management", "Consistency"]
  }
)
```

## I18n Prompts Usage

### Directory Structure

```
app/prompts/
├── user_onboarding/
│   ├── welcome_email.en.erb          # English AI prompt
│   ├── welcome_email.es.erb          # Spanish AI prompt
│   └── onboarding_checklist.erb      # Fallback (any locale)
├── content_generation/
│   ├── blog_post_outline.en.erb
│   ├── social_media_post.es.erb
│   └── product_description.erb
└── ai_coaching/
    ├── goal_review.en.liquid          # Liquid AI prompt
    └── goal_review.es.liquid
```

### Locale Resolution

Promptly follows this resolution order:

1. **Requested locale**: `welcome.es.erb` (if `locale: :es` specified)
2. **Default locale**: `welcome.en.erb` (if `I18n.default_locale == :en`)
3. **Fallback**: `welcome.erb` (no locale suffix)

```ruby
# Configure I18n in your Rails app
# config/application.rb
config.i18n.default_locale = :en
config.i18n.available_locales = [:en, :es, :fr]

# Usage examples
I18n.locale = :es
I18n.default_locale = :en

# Will try: welcome_email.es.erb → welcome_email.en.erb → welcome_email.erb
prompt = Promptly.render(
  "user_onboarding/welcome_email", 
  locals: {
    name: "María García",
    app_name: "ProjectHub",
    user_role: "Manager",
    features: ["Team management", "Analytics", "Reporting"],
    days_since_signup: 1
  }
)

# Force specific locale for AI prompt generation
prompt = Promptly.render(
  "content_generation/blog_post_outline", 
  locale: :fr, 
  locals: {
    topic: "Intelligence Artificielle",
    target_audience: "Développeurs",
    word_count: 1500
  }
)
```

### Liquid Templates

For more complex templating needs, use Liquid:

```liquid
<!-- app/prompts/ai_coaching/goal_review.en.liquid -->
You are an experienced life coach conducting a goal review session.

Context:
- Client name: {{ user_name }}
- Goals being reviewed: {% for goal in current_goals %}{{ goal }}{% unless forloop.last %}, {% endunless %}{% endfor %}
- Recent progress: {{ progress_summary }}
- Current challenges: {% for challenge in challenges %}{{ challenge }}{% unless forloop.last %}, {% endunless %}{% endfor %}
- Review period: {{ review_period | default: "monthly" }}

Task: Provide a personalized goal review that:
1. Acknowledges their progress and celebrates wins
2. Addresses each challenge with specific, actionable advice
3. Suggests 2-3 concrete next steps for the coming {{ review_period }}
4. Asks 1-2 thoughtful questions to help them reflect
5. Maintains an encouraging but realistic tone

{% if current_goals.size > 5 %}
Note: The client has many goals. Help them prioritize the most important ones.
{% endif %}

Format your response as a conversational coaching session, not a formal report.
```

```ruby
# Generate AI coaching content with Liquid template
prompt = Promptly.render(
  "ai_coaching/goal_review",
  locale: :en,
  locals: {
    user_name: "Alex",
    current_goals: ["Run 5K under 25min", "Gym 3x/week", "Read 12 books/year"],
    progress_summary: "Consistent with gym, behind on running pace, ahead on reading",
    challenges: ["Time management", "Motivation on rainy days"],
    review_period: "monthly"
  }
)

# Send to AI service for personalized coaching
ai_coaching_session = openai_client.chat(
  model: "gpt-4",
  messages: [{role: "user", content: prompt}]
).dig("choices", 0, "message", "content")
```

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

## API Reference

### `Promptly.render(identifier, locale: nil, locals: {}, cache: true, ttl: nil)`

Renders a template by identifier with locale fallback and optional caching.

- **identifier**: Template path like `"user_onboarding/welcome"`
- **locale**: Specific locale (defaults to `I18n.locale`)
- **locals**: Hash of variables for template
- **cache**: Enable/disable caching for this call (defaults to `true`)
- **ttl**: Time-to-live in seconds for cache entry (overrides default TTL)

### `Promptly.render_template(template, locals: {}, engine: :erb)`

Renders template string directly.

- **template**: Template string
- **locals**: Hash of variables
- **engine**: `:erb` or `:liquid`

### `Promptly.prompts_path`

Get/set the root directory for prompt templates (defaults to `Rails.root/app/prompts`).

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
