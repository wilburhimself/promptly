# frozen_string_literal: true

require "spec_helper"
require "json"

RSpec.describe Promptly do
  describe ".response_format" do
    let(:identifier) { "test_interaction" }
    let(:schema_path) { File.join(Promptly.prompts_path, "#{identifier}.response.json") }
    let(:schema_content) do
      {
        "type" => "object",
        "properties" => {
          "reply" => {"type" => "string"}
        },
        "required" => ["reply"],
        "additionalProperties" => false
      }
    end

    before do
      allow(Promptly).to receive(:prompts_path).and_return(File.expand_path("support/prompts", __dir__))
      FileUtils.mkdir_p(Promptly.prompts_path)
      File.write(schema_path, schema_content.to_json)
    end

    after do
      FileUtils.rm_f(schema_path)
    end

    it "returns the structured output format for OpenAI" do
      result = Promptly.response_format(identifier)
      
      expect(result).to eq({
        type: "json_schema",
        json_schema: {
          name: "test_interaction",
          strict: true,
          schema: schema_content
        }
      })
    end

    it "raises an error if the schema file does not exist" do
      FileUtils.rm_f(schema_path)
      expect { Promptly.response_format(identifier) }.to raise_error(Promptly::Error, /Schema file not found/)
    end
  end

  describe ".validate_response!" do
    let(:identifier) { "test_validation" }
    let(:schema_path) { File.join(Promptly.prompts_path, "#{identifier}.response.json") }
    let(:schema_content) do
      {
        "type" => "object",
        "properties" => {
          "status" => {"type" => "string", "enum" => ["success", "error"]}
        },
        "required" => ["status"]
      }
    end

    before do
      allow(Promptly).to receive(:prompts_path).and_return(File.expand_path("support/prompts", __dir__))
      FileUtils.mkdir_p(Promptly.prompts_path)
      File.write(schema_path, schema_content.to_json)
    end

    after do
      FileUtils.rm_f(schema_path)
    end

    it "returns parsed JSON when valid" do
      valid_json = '{"status": "success"}'
      result = Promptly.validate_response!(identifier, valid_json)
      expect(result).to eq({"status" => "success"})
    end

    it "raises ValidationError when invalid" do
      invalid_json = '{"status": "unknown"}'
      expect { Promptly.validate_response!(identifier, invalid_json) }.to raise_error(Promptly::ValidationError, /does not match schema/)
    end
  end
end
