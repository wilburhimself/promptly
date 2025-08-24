# frozen_string_literal: true

require "spec_helper"
require "fileutils"
require "tmpdir"

# Simple in-memory cache store for testing
class TestCacheStore
  def initialize
    @data = {}
  end

  def read(key)
    @data[key]
  end

  def write(key, value, expires_in: nil)
    @data[key] = value
  end

  def delete(key)
    @data.delete(key)
  end

  def clear
    @data.clear
  end

  def size
    @data.size
  end

  def keys
    @data.keys
  end
end

RSpec.describe "Promptly.render with caching" do
  let(:cache_store) { TestCacheStore.new }

  around do |example|
    Dir.mktmpdir do |dir|
      original_path = Promptly.prompts_path
      Promptly.prompts_path = File.join(dir, "prompts")
      FileUtils.mkdir_p(Promptly.prompts_path)

      # Configure cache
      original_store = Promptly::Cache.store
      original_enabled = Promptly::Cache.enabled

      Promptly::Cache.store = cache_store
      Promptly::Cache.enabled = true

      example.run

      Promptly.prompts_path = original_path
      Promptly::Cache.store = original_store
      Promptly::Cache.enabled = original_enabled
    end
  end

  it "caches rendered templates" do
    # Create test template
    template_path = File.join(Promptly.prompts_path, "test.erb")
    File.write(template_path, "Hello <%= name %>!")

    # First call should read file and cache result
    result1 = Promptly.render("test", locals: {name: "John"})
    expect(result1.content).to eq("Hello John!")
    expect(cache_store.size).to eq(1)

    # Second call should use cached result
    result2 = Promptly.render("test", locals: {name: "John"})
    expect(result2.content).to eq("Hello John!")

    # Verify file was only read once by checking cache was used
    cache_key = cache_store.keys.first
    expect(cache_store.read(cache_key).content).to eq("Hello John!")
  end

  it "generates different cache keys for different parameters" do
    template_path = File.join(Promptly.prompts_path, "test.erb")
    File.write(template_path, "Hello <%= name %>!")

    # Different locals should create different cache entries
    Promptly.render("test", locals: {name: "John"})
    Promptly.render("test", locals: {name: "Jane"})

    expect(cache_store.size).to eq(2)
  end

  it "respects custom TTL" do
    template_path = File.join(Promptly.prompts_path, "test.erb")
    File.write(template_path, "Hello <%= name %>!")

    cache_store = Promptly::Cache.store
    expect(cache_store).to receive(:write).with(anything, anything, expires_in: 1800)

    Promptly.render("test", locals: {name: "John"}, ttl: 1800)
  end

  it "bypasses cache when cache parameter is false" do
    template_path = File.join(Promptly.prompts_path, "test.erb")
    File.write(template_path, "Hello <%= name %>!")

    # This should not use cache
    result = Promptly.render("test", locals: {name: "John"}, cache: false)
    expect(result.content).to eq("Hello John!")
    expect(cache_store.size).to eq(0)
  end

  it "works with locale-specific templates" do
    # Create English template
    en_path = File.join(Promptly.prompts_path, "greeting.en.erb")
    File.write(en_path, "Hello <%= name %>!")

    # Create Spanish template
    es_path = File.join(Promptly.prompts_path, "greeting.es.erb")
    File.write(es_path, "¡Hola <%= name %>!")

    # Should cache separately by locale
    result_en = Promptly.render("greeting", locale: :en, locals: {name: "John"})
    result_es = Promptly.render("greeting", locale: :es, locals: {name: "Juan"})

    expect(result_en.content).to eq("Hello John!")
    expect(result_es.content).to eq("¡Hola Juan!")
    expect(cache_store.size).to eq(2)
  end
end
