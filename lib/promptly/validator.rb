module Promptly
  class Validator
    def self.validate!(locals, schema_path)
      return unless File.exist?(schema_path)

      schema = YAML.load_file(schema_path)
      missing_keys = schema.keys - locals.keys.map(&:to_s)
      unless missing_keys.empty?
        raise ArgumentError, "Missing required locals: #{missing_keys.join(", ")}"
      end

      # Optional: type checking
      schema.each do |key, type|
        next unless locals.key?(key.to_sym)
        value = locals[key.to_sym]
        case type
        when "string" then raise TypeError unless value.is_a?(String)
        when "integer" then raise TypeError unless value.is_a?(Integer)
        when "array" then raise TypeError unless value.is_a?(Array)
        end
      end
    end
  end
end
