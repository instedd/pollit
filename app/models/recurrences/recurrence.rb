module Recurrences
  module Recurrence
    extend ActiveSupport::Concern

    module ClassMethods
      def has_recurrence(attribute)
        # TODO attr_accessible if attr_accessible is been used
        # for attribute and attribute_rule

        self.send :attr_accessor, attribute

        define_method attribute do
          yaml = read_attribute(attribute)
          data = YAML.load(yaml.to_s)
          if yaml.nil?
            IceCube::Schedule.new
          elsif data.is_a?(String)
            # icecube deserealization of recurrences without rules
            IceCube::Schedule.new(Time.parse(data))
          else
            IceCube::Schedule.from_yaml(yaml)
          end
        end

        define_method "#{attribute}=" do |schedule|
          write_attribute(attribute, schedule.to_yaml)
        end

        define_method "#{attribute}_rule" do
          self.send(attribute).recurrence_rules.first
        end

        define_method "#{attribute}_rule=" do |rule|
          if rule.is_a?(String)
            if rule == 'null'
              rule = nil
            else
              rule = IceCube::Rule.from_hash(JSON.parse(rule))
            end
          end

          schedule = self.send(attribute)
          schedule.recurrence_rules.each do |r|
            schedule.remove_recurrence_rule r
          end

          schedule.add_recurrence_rule(rule) if !rule.nil?
          self.send("#{attribute}=", schedule)
        end

        define_method "#{attribute}_start_time" do
          self.send(attribute).start_time
        end

        define_method "#{attribute}_start_time=" do |value|
          schedule = self.send(attribute)
          schedule.start_time = value
          self.send "#{attribute}=", schedule
        end
      end
    end
  end
end
