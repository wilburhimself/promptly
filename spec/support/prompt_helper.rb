module PromptHelper
  def expect_prompt_render(identifier, locals: {})
    RSpec::Matchers::BuiltIn::Include.new(Promptly.render(identifier, locals: locals))
  end
end
