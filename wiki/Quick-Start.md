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
