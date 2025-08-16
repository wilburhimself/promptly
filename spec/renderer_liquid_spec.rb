# frozen_string_literal: true

require "spec_helper"

RSpec.describe Promptly::Renderer do
  describe ".render with Liquid" do
    it "renders Liquid with locals" do
      begin
        require "liquid"
      rescue LoadError
        skip "liquid gem not installed"
      end

      out = described_class.render("Hello {{ name }}", locals: {name: "Sam"}, engine: :liquid)
      expect(out.strip).to eq("Hello Sam")
    end
  end
end
