# frozen_string_literal: true

require "spec_helper"
require "liquid"

RSpec.describe RailsAiPrompts::Renderer do
  describe ".render with Liquid" do
    it "renders Liquid with locals" do
      out = described_class.render("Hello {{ name }}", locals: {name: "Sam"}, engine: :liquid)
      expect(out.strip).to eq("Hello Sam")
    end
  end
end
