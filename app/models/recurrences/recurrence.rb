module Recurrences
  module Recurrence
    extend ActiveSupport::Concern

    module ClassMethods
      def has_recurrence(attribute)
        self.send :attr_accessible, attribute
        self.send :serialize, attribute

        define_method attribute do
          Recurrences::Base.to_obj read_attribute(attribute) || :none
        end

        define_method "#{attribute}=" do |value|
          value = value.serialize if value.is_a?(Recurrences::Base)
          write_attribute(attribute, value)
        end
      end
    end
  end
end
