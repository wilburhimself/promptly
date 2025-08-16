# frozen_string_literal: true

require "spec_helper"
require "rake"
require "fileutils"
require "tmpdir"

RSpec.describe "ai_prompts:preview rake task" do
  let(:rake) { Rake::Application.new }

  before do
    # Use our own Rake app and satisfy environment dependency on it
    Rake.application = rake
    rake.define_task(Rake::Task, :environment)

    # Load our rake tasks on this app
    load File.expand_path("../lib/rails_ai_prompts/tasks/ai_prompts.rake", __dir__)
  end

  after do
    Rake.application = nil
  end

  it "prints rendered output for the given identifier and locale" do
    Dir.mktmpdir do |dir|
      root = File.join(dir, "app", "prompts", "user_onboarding")
      FileUtils.mkdir_p(root)
      File.write(File.join(root, "welcome.en.erb"), "Hello <%= name %>")

      RailsAiPrompts.prompts_path = File.join(dir, "app", "prompts")

      task = rake["ai_prompts:preview"]

      out, err = capture_io do
        task.reenable # allow multiple invocations in same process
        task.invoke("user_onboarding/welcome", "en")
      end

      expect(err).to eq("")
      expect(out.strip).to eq("Hello ") # locals are not provided via CLI, so blank suffix
    ensure
      RailsAiPrompts.prompts_path = nil
      task&.reenable
      # silence rubocop about unused err
    end
  end

  def capture_io
    orig_out, orig_err = $stdout, $stderr
    out, err = StringIO.new, StringIO.new
    $stdout = out
    $stderr = err
    yield
    [out.string, err.string]
  ensure
    $stdout = orig_out
    $stderr = orig_err
  end
end
