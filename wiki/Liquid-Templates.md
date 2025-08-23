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
