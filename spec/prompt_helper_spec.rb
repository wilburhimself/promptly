require "spec_helper"

RSpec.describe PromptHelper do
  describe "#expect_prompt_render" do
    it "renders the prompt" do
      expect("This is a test prompt.").to expect_prompt_render("test/prompt")
    end

    it "renders the prompt with metadata" do
      prompt = Promptly.render("test/prompt_with_metadata")
      expect(prompt.to_s).to eq("This is a test prompt with metadata.")
      expect(prompt.version).to eq(1.0)
      expect(prompt.author).to eq("Test Author")
      expect(prompt.change_notes).to eq("Initial version")
    end
  end
end
