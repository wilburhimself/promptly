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
