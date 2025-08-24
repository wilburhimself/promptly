## Functional Prompt Tests

Promptly provides an RSpec helper to write functional tests for your prompts. This allows you to verify the rendered output of your prompts, ensuring that they are correctly formatted and that all variables are properly interpolated.

### RSpec Helper

The `expect_prompt_render` helper is available in your RSpec tests. It takes the prompt identifier and a hash of locals as arguments.

**Example:**

```ruby
# spec/prompts/user_onboarding/welcome_email_spec.rb
require "spec_helper"

RSpec.describe "user_onboarding/welcome_email" do
  it "renders the welcome email correctly" do
    locals = {
      name: "John Doe",
      app_name: "My App",
      user_role: "Admin",
      features: ["Feature 1", "Feature 2"],
      days_since_signup: 5
    }

    expect(Promptly.render("user_onboarding/welcome_email", locals: locals)).to include("Hello John Doe")
  end
end
```

### Rake Task

You can run all your prompt tests using the `ai_prompts:test_prompts` Rake task.

```bash
rake ai_prompts:test_prompts
```
