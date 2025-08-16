# frozen_string_literal: true

require "uri"
require "action_view"

module Promptly
  class Renderer
    def self.render(template, locals: {}, engine: :erb)
      case engine.to_sym
      when :erb
        render_erb(template, locals)
      when :liquid
        render_liquid(template, locals)
      else
        raise ArgumentError, "Unsupported engine: #{engine} (use :erb or :liquid)"
      end
    end

    def self.render_erb(template, locals)
      view_class = if ActionView::Base.respond_to?(:with_empty_template_cache)
        ActionView::Base.with_empty_template_cache
      else
        Class.new(ActionView::Base)
      end

      lookup = ActionView::LookupContext.new(ActionView::PathSet.new([]))
      av = view_class.new(lookup, {}, nil)

      av.render(inline: template, type: :erb, locals: locals || {})
    end

    def self.render_liquid(template, locals)
      unless defined?(::Liquid)
        raise LoadError, "Liquid is not available. Add `gem 'liquid'` to your Gemfile to use :liquid engine."
      end

      stringified = (locals || {}).each_with_object({}) do |(k, v), h|
        h[k.to_s] = v
      end

      ::Liquid::Template.parse(template).render(stringified)
    end

    private_class_method :render_erb, :render_liquid
  end
end
