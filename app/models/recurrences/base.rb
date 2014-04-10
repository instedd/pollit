module Recurrences
  class Base

    def initialize(options = {})
      options = options.with_indifferent_access

      (options || {}).each do |key, value|
        self.send("#{key}=", value)
      end
    end

    def next_date(from)
    end

    def kind
      k = serialize
      k = k.keys.first if k.is_a?(Hash)
      k.to_sym
    end

    def serialize
      raise 'not implemented'
    end

    def self.to_obj(value)
      if value.is_a?(String) || value.is_a?(Symbol)
        kind = value.to_sym
        options = nil
      elsif value.is_a?(Hash) && value.keys.length == 1
        kind = value.keys.first.to_sym
        options = value.values.first
      else
        raise 'not implemented'
      end


      if kind == :none
        None.new
      elsif kind == :weekly
        Weekly.new(options)
      else
        raise 'not implemented'
      end
    end
  end
end
