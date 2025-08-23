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
