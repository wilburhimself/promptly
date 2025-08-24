require "spec_helper"

RSpec.describe "test/prompt.en.erb" do
  it "renders correctly" do
    expect("This is a test prompt.").to expect_prompt_render("test/prompt")
  end
end
