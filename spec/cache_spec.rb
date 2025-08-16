# frozen_string_literal: true

require "spec_helper"

RSpec.describe Promptly::Cache do
  let(:memory_store) { double("memory_store") }

  before do
    described_class.store = memory_store
    described_class.enabled = true
    described_class.ttl = 3600
  end

  after do
    described_class.store = nil
    described_class.enabled = true
    described_class.ttl = 3600
  end

  describe ".fetch" do
    context "when cache is enabled" do
      it "returns cached value if present" do
        cache_key = "promptly:test_key"
        cached_value = "cached result"

        allow(memory_store).to receive(:read).with(cache_key).and_return(cached_value)

        result = described_class.fetch("test_key") { "fresh result" }

        expect(result).to eq(cached_value)
      end

      it "executes block and caches result if not present" do
        cache_key = "promptly:test_key"
        fresh_value = "fresh result"

        allow(memory_store).to receive(:read).with(cache_key).and_return(nil)
        expect(memory_store).to receive(:write).with(cache_key, fresh_value, expires_in: 3600)

        result = described_class.fetch("test_key") { fresh_value }

        expect(result).to eq(fresh_value)
      end

      it "uses custom TTL when provided" do
        cache_key = "promptly:test_key"
        fresh_value = "fresh result"
        custom_ttl = 1800

        allow(memory_store).to receive(:read).with(cache_key).and_return(nil)
        expect(memory_store).to receive(:write).with(cache_key, fresh_value, expires_in: custom_ttl)

        described_class.fetch("test_key", ttl: custom_ttl) { fresh_value }
      end

      it "generates hash-based cache key for complex data" do
        complex_key = {identifier: "test", locale: :en, locals: {name: "John"}}
        expected_hash = Digest::SHA256.hexdigest(complex_key.sort.to_s)
        cache_key = "promptly:#{expected_hash}"

        allow(memory_store).to receive(:read).with(cache_key).and_return(nil)
        expect(memory_store).to receive(:write).with(cache_key, "result", expires_in: 3600)

        described_class.fetch(complex_key) { "result" }
      end
    end

    context "when cache is disabled" do
      before { described_class.enabled = false }

      it "always executes block without caching" do
        expect(memory_store).not_to receive(:read)
        expect(memory_store).not_to receive(:write)

        result = described_class.fetch("test_key") { "fresh result" }

        expect(result).to eq("fresh result")
      end
    end

    context "when no store is configured" do
      before { described_class.store = nil }

      it "always executes block without caching" do
        result = described_class.fetch("test_key") { "fresh result" }

        expect(result).to eq("fresh result")
      end
    end
  end

  describe ".clear" do
    it "clears the cache store if supported" do
      expect(memory_store).to receive(:clear)

      described_class.clear
    end

    it "does nothing if store doesn't support clear" do
      allow(memory_store).to receive(:respond_to?).with(:clear).and_return(false)

      expect { described_class.clear }.not_to raise_error
    end
  end

  describe ".delete" do
    it "deletes specific cache key" do
      cache_key = "promptly:test_key"

      expect(memory_store).to receive(:delete).with(cache_key)

      described_class.delete("test_key")
    end
  end
end
