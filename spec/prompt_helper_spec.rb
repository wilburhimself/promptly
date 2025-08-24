require "spec_helper"

RSpec.describe PromptHelper do
  describe "#expect_prompt_render" do
    it "renders the prompt" do
      expect("This is a test prompt.").to expect_prompt_render("test/prompt")
    end
  end
end
