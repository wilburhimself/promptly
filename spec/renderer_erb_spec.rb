# frozen_string_literal: true

require "spec_helper"

RSpec.describe Promptly::Renderer do
  describe ".render with ERB" do
    it "renders ERB with locals" do
      out = described_class.render("Hello <%= name %>", locals: {name: "Sam"}, engine: :erb)
      expect(out.strip).to eq("Hello Sam")
    end
  end
end
