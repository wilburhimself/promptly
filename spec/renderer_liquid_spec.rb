# frozen_string_literal: true

require "spec_helper"

begin
  require "liquid"
rescue LoadError
  RSpec.describe "Liquid rendering" do
    it "skips when liquid gem is not installed" do
      skip "liquid gem not installed"
    end
  end
  return
end

RSpec.describe RailsAiPrompts::Renderer do
  describe ".render with Liquid" do
    it "renders Liquid with locals" do
      out = described_class.render("Hello {{ name }}", locals: {name: "Sam"}, engine: :liquid)
      expect(out.strip).to eq("Hello Sam")
    end
  end
end
