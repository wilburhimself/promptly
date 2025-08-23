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
