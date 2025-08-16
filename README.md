# rails_ai_prompts

Opinionated Rails integration for reusable AI prompt templates. Build maintainable, localized, and testable AI prompts using ERB or Liquid templates with Rails conventions.

## Features

- **Template rendering**: ERB (via ActionView) and optional Liquid support
- **I18n integration**: Automatic locale fallback (`welcome.es.erb` → `welcome.en.erb` → `welcome.erb`)
- **Rails conventions**: Store prompts in `app/prompts/` with organized subdirectories
- **Preview & CLI**: Test prompts in Rails console or via rake tasks
- **Minimal setup**: Auto-loads via Railtie, zero configuration required

## Install

Add to your Gemfile:

```ruby
gem "rails_ai_prompts"
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

Create `app/prompts/user_onboarding/welcome.en.erb`:

```erb
Hello <%= name %>,

Welcome to <%= app_name %>! Here's what you can do:

<% features.each do |feature| %>
- <%= feature %>
<% end %>

Best regards,
The <%= app_name %> Team
```

Create `app/prompts/user_onboarding/welcome.es.erb`:

```erb
Hola <%= name %>,

¡Bienvenido a <%= app_name %>! Esto es lo que puedes hacer:

<% features.each do |feature| %>
- <%= feature %>
<% end %>

Saludos,
El equipo de <%= app_name %>
```

### 2. Render in your Rails app

```ruby
# In a controller, service, or anywhere in Rails
output = RailsAiPrompts.preview(
  "user_onboarding/welcome",
  locale: :es,
  locals: {
    name: "María",
    app_name: "MyApp",
    features: ["Create projects", "Invite team members", "Track progress"]
  }
)

puts output
# => "Hola María,\n\n¡Bienvenido a MyApp! ..."
```

### 3. Test via Rails console

```ruby
rails console

# Preview with specific locale
RailsAiPrompts.preview("user_onboarding/welcome", locale: :en, locals: {name: "John", app_name: "MyApp", features: ["Feature 1"]})

# Uses I18n.locale by default
I18n.locale = :es
RailsAiPrompts.preview("user_onboarding/welcome", locals: {name: "María", app_name: "MyApp", features: ["Función 1"]})
```

### 4. CLI preview

```bash
# Preview specific locale
rails ai_prompts:preview[user_onboarding/welcome,es]

# Uses default locale
rails ai_prompts:preview[user_onboarding/welcome]
```

## Rails App Integration

### Service Object Pattern

```ruby
# app/services/ai_prompt_service.rb
class AiPromptService
  def self.generate_welcome_email(user, locale: I18n.locale)
    RailsAiPrompts.preview(
      "user_onboarding/welcome",
      locale: locale,
      locals: {
        name: user.name,
        app_name: Rails.application.class.module_parent_name,
        features: current_features_for(user)
      }
    )
  end

  private

  def self.current_features_for(user)
    # Return features based on user's plan, role, etc.
    ["Create projects", "Invite team members"]
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
# app/jobs/send_ai_notification_job.rb
class SendAiNotificationJob < ApplicationJob
  def perform(user_id, prompt_identifier, locals = {})
    user = User.find(user_id)
    
    content = RailsAiPrompts.preview(
      prompt_identifier,
      locale: user.locale,
      locals: locals.merge(user_name: user.name)
    )
    
    # Send to AI service, email, SMS, etc.
    AiService.send_prompt(content)
  end
end

# Usage
SendAiNotificationJob.perform_later(
  user.id,
  "notifications/project_reminder",
  {project_name: "My Project", due_date: "tomorrow"}
)
```

## I18n Prompts Usage

### Directory Structure

```
app/prompts/
├── user_onboarding/
│   ├── welcome.en.erb          # English
│   ├── welcome.es.erb          # Spanish
│   ├── welcome.fr.erb          # French
│   └── welcome.erb             # Fallback (any locale)
├── notifications/
│   ├── project_reminder.en.erb
│   ├── project_reminder.es.erb
│   └── daily_digest.erb        # Single template for all locales
└── ai_coaching/
    ├── goal_setting.en.liquid  # Liquid template
    └── goal_setting.es.liquid
```

### Locale Resolution

RailsAiPrompts follows this resolution order:

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

# Will try: welcome.es.erb → welcome.en.erb → welcome.erb
RailsAiPrompts.preview("user_onboarding/welcome", locals: {name: "María"})

# Force specific locale
RailsAiPrompts.preview("user_onboarding/welcome", locale: :fr, locals: {name: "Pierre"})
```

### Liquid Templates

For more complex templating needs, use Liquid:

```liquid
<!-- app/prompts/ai_coaching/goal_setting.en.liquid -->
Hi {{ user_name }},

Let's work on your {{ goal_type }} goals:

{% for goal in goals %}
  {{ forloop.index }}. {{ goal.title }}
     Target: {{ goal.target }}
     Deadline: {{ goal.deadline | date: "%B %d, %Y" }}
{% endfor %}

{% if goals.size > 3 %}
You're ambitious! Consider focusing on your top 3 goals first.
{% endif %}

Best of luck!
```

```ruby
# Render Liquid template
RailsAiPrompts.preview(
  "ai_coaching/goal_setting",
  locale: :en,
  locals: {
    user_name: "Alex",
    goal_type: "fitness",
    goals: [
      {title: "Run 5K", target: "under 25 minutes", deadline: 1.month.from_now},
      {title: "Gym 3x/week", target: "consistency", deadline: 3.months.from_now}
    ]
  }
)
```

## Configuration

### Custom Prompts Path

```ruby
# config/initializers/rails_ai_prompts.rb
RailsAiPrompts.prompts_path = Rails.root.join("lib", "ai_prompts")
```

### Direct Template Rendering

```ruby
# Render ERB directly (without file lookup)
template = "Hello <%= name %>, welcome to <%= app %>!"
output = RailsAiPrompts.render(template, locals: {name: "John", app: "MyApp"})

# Render Liquid directly
template = "Hello {{ name }}, welcome to {{ app }}!"
output = RailsAiPrompts.render(template, locals: {name: "John", app: "MyApp"}, engine: :liquid)
```

## API Reference

### `RailsAiPrompts.preview(identifier, locale: nil, locals: {})`

Renders a template by identifier with locale fallback.

- **identifier**: Template path like `"user_onboarding/welcome"`
- **locale**: Specific locale (defaults to `I18n.locale`)
- **locals**: Hash of variables for template

### `RailsAiPrompts.render(template, locals: {}, engine: :erb)`

Renders template string directly.

- **template**: Template string
- **locals**: Hash of variables
- **engine**: `:erb` or `:liquid`

### `RailsAiPrompts.prompts_path`

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
