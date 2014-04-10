module Recurrences
  module Recurrence
    extend ActiveSupport::Concern

    module ClassMethods
      def has_recurrence(attribute)
        self.send :attr_accessor, attribute
        self.send :serialize, attribute

        self.send :before_save do
          # so changes to the recurrence are persisted
          self.send "#{attribute}=", (self.send attribute)
        end

        define_method attribute do
          # memoized object in order to make changes
          self.instance_variable_set("@#{attribute}",
            self.instance_variable_get("@#{attribute}") || Recurrences::Base.to_obj(read_attribute(attribute) || :none)
          )
        end

        define_method "#{attribute}=" do |value|
          self.instance_variable_set("@#{attribute}", nil)
          value = value.serialize if value.is_a?(Recurrences::Base)
          write_attribute(attribute, value)
        end
      end
    end
  end
end
