# frozen_string_literal: true

require "action_view"

module RailsAiPrompts
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
      av = if ActionView::Base.respond_to?(:empty)
        ActionView::Base.empty
      else
        ActionView::Base.new(ActionView::LookupContext.new([]), {}, nil)
      end

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
