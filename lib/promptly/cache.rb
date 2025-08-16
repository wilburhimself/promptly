# frozen_string_literal: true

require "digest"

module Promptly
  class Cache
    class << self
      attr_accessor :store, :enabled, :ttl

      def configure
        yield self
      end

      def enabled?
        @enabled != false && store
      end

      def fetch(key, ttl: nil, &block)
        return yield unless enabled?

        cache_key = generate_key(key)
        cached_value = store.read(cache_key)

        if cached_value
          cached_value
        else
          value = yield
          store.write(cache_key, value, expires_in: ttl || self.ttl)
          value
        end
      end

      def clear
        return unless enabled? && store.respond_to?(:clear)

        store.clear
      end

      def delete(key)
        return unless enabled?

        cache_key = generate_key(key)
        store.delete(cache_key)
      end

      private

      def generate_key(key_data)
        case key_data
        when String
          "promptly:#{key_data}"
        when Hash
          content = key_data.sort.to_s
          hash = Digest::SHA256.hexdigest(content)
          "promptly:#{hash}"
        else
          "promptly:#{Digest::SHA256.hexdigest(key_data.to_s)}"
        end
      end
    end

    # Default configuration
    self.enabled = true
    self.ttl = 3600 # 1 hour default TTL
    self.store = nil
  end
end
