# frozen_string_literal: true

namespace :ai_prompts do
  desc "Render a prompt: rake ai_prompts:render[identifier,locale]"
  task :render, [:identifier, :locale] => :environment do |_, args|
    identifier = args[:identifier]
    locale = args[:locale]
    prompts_path = ENV["PROMPTS_PATH"]

    unless identifier
      warn "Usage: rake ai_prompts:render[identifier,locale]"
      exit 1
    end

    begin
      Promptly.prompts_path = prompts_path if prompts_path

      output = Promptly.render(identifier, locale: locale)
      puts output
    rescue Promptly::Error => e
      warn "Error: #{e.class}: #{e.message}"
      exit 1
    end
  end

  desc "Lint prompt templates. Usage: rake ai_prompts:lint[identifier] LOCALES=en,es REQUIRED=name,app_name PROMPTS_PATH=..."
  task :lint, [:identifier] => :environment do |_, args|
    require "erb"

    prompts_path = ENV["PROMPTS_PATH"] || Promptly.prompts_path
    identifier_filter = args[:identifier]

    locales = if ENV["LOCALES"]
      ENV["LOCALES"].split(",").map(&:strip).reject(&:empty?)
    elsif defined?(I18n) && I18n.respond_to?(:available_locales)
      I18n.available_locales.map(&:to_s)
    else
      []
    end

    required_keys = (ENV["REQUIRED"] || "").split(",").map(&:strip).reject(&:empty?)

    unless File.directory?(prompts_path)
      warn "[lint] prompts_path not found: #{prompts_path}"
      exit 1
    end

    exts = Promptly::Locator::SUPPORTED_EXTS

    files = Dir.glob(File.join(prompts_path, "**", "*{#{exts.join(",")}}"))
    if identifier_filter
      files.select! do |f|
        # match by identifier path without locale/ext
        rel = f.sub(/^#{Regexp.escape(prompts_path)}\//, "")
        base = rel.sub(/\.(?:[a-z]{2})?(?:#{exts.map { |e| Regexp.escape(e) }.join("|")})\z/, "")
        base == identifier_filter
      end
    end

    if files.empty?
      warn "[lint] No templates found under #{prompts_path}#{identifier_filter ? " for '#{identifier_filter}'" : ""}"
      exit 1
    end

    status = 0

    # Group by identifier (path without locale/ext)
    grouped = files.group_by do |f|
      rel = f.sub(/^#{Regexp.escape(prompts_path)}\//, "")
      rel.sub(/\.(?:[a-z]{2})?(?:#{exts.map { |e| Regexp.escape(e) }.join("|")})\z/, "")
    end

    grouped.each do |identifier, paths|
      puts "[lint] Identifier: #{identifier}"

      # 1) Syntax check and placeholder scan per file
      paths.each do |path|
        engine = Promptly::Locator.engine_for(path)
        content = File.read(path)

        begin
          case engine
          when :erb
            # Compile ERB to Ruby, don't execute
            ERB.new(content)
          when :liquid
            if defined?(::Liquid)
              ::Liquid::Template.parse(content)
            else
              warn "  - WARN: Liquid not available; skipping syntax parse for #{File.basename(path)}"
            end
          end
        rescue => e
          warn "  - ERROR: Syntax error in #{File.basename(path)}: #{e.class}: #{e.message}"
          status = 1
        end

        # Required placeholder presence (best-effort scan)
        if required_keys.any?
          missing = []
          required_keys.each do |key|
            present = false
            case engine
            when :erb
              # naive checks: @key or key inside ERB output tags
              present ||= content.match?(/<%[=\-].*?@#{Regexp.escape(key)}[\W]/m)
              present ||= content.match?(/<%[=\-].*?\b#{Regexp.escape(key)}\b/m)
            when :liquid
              present ||= content.match?(/\{\{\s*#{Regexp.escape(key)}[\s\|\}]/)
            end
            missing << key unless present
          end
          if missing.any?
            warn "  - ERROR: Missing required placeholders in #{File.basename(path)}: #{missing.join(", ")}"
            status = 1
          end
        end
      end

      # 2) Missing locale files (if locales provided)
      if locales.any?
        found_locales = paths.map do |p|
          # extract locale between name and extension: name.<locale>.ext
          File.basename(p)[/\.([a-z]{2})\.(?:erb|liquid)\z/, 1]
        end.compact.uniq

        missing_locales = locales - found_locales
        if missing_locales.any?
          warn "  - WARN: Missing locale templates for #{identifier}: #{missing_locales.join(", ")}"
        else
          puts "  - OK: Locale coverage satisfied"
        end
      end
    end

    if status.zero?
      puts "[lint] OK"
    else
      warn "[lint] FAIL"
    end
    exit status
  end

  desc "Run functional tests for prompts"
  task :test_prompts do
    exec "bundle exec rspec spec/prompts"
  end
end
