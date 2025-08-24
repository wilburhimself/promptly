## Prompt Version Metadata

Promptly allows you to add optional metadata fields to your prompt templates, such as `version`, `author`, and `change_notes`. This metadata can be useful for tracking changes to your prompts and for documentation purposes.

### Adding Metadata to Prompts

To add metadata to a prompt, include a YAML front matter block at the beginning of your template file. The front matter block must start and end with `---`.

**Example:**

```erb
---
version: 1.0
author: John Doe
change_notes: Initial version of the welcome email.
---
You are a friendly customer success manager writing a personalized welcome email.
...
```

### Accessing Metadata

When you render a prompt, the `Promptly.render` method returns a `Prompt` object. This object contains the rendered content of the prompt, as well as the metadata fields.

**Example:**

```ruby
prompt = Promptly.render("user_onboarding/welcome_email")

puts prompt.content        # The rendered content of the email
puts prompt.version        # 1.0
puts prompt.author         # John Doe
puts prompt.change_notes   # Initial version of the welcome email.
```
