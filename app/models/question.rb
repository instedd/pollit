# Copyright (C) 2011-2012, InSTEDD
#
# This file is part of Pollit.
#
# Pollit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Pollit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Pollit.  If not, see <http://www.gnu.org/licenses/>.

class Question < ActiveRecord::Base
  OptionsIndices = Array('a'..'z')

  belongs_to :poll, :inverse_of => :questions
  has_many :answers

  validates :title, :presence => true
  validates :field_name, :presence => true, :if => lambda{|q| q.poll && q.poll.kind_gforms?}
  validates :position, :presence => true
  validates :options, :presence => true, :if => :kind_options?
  validates :message, :length => {:maximum => 140}

  validate  :kind_supported

  validates_numericality_of :numeric_min, :only_integer => true, :if => lambda{|q| q.kind_numeric? && q.numeric_min }
  validates_numericality_of :numeric_max, :only_integer => true, :if => lambda{|q| q.kind_numeric? && q.numeric_max }

  acts_as_list :scope => :poll
  alias_method :next, :lower_item

  serialize :options, Array
  serialize :next_question_definition, Hash
  serialize :custom_messages, Hash

  enum_attr :kind, %w(^text options numeric unsupported)

  after_save :touch_user_lifespan
  after_destroy :touch_user_lifespan

  before_save :merge_options_and_keys

  attr_accessor :keys

  def message
    if kind_text?
      title
    elsif numeric?
      "#{title} #{numeric_min}-#{numeric_max}"
    elsif kind_options?
      if explanation = custom_message("options_explanation")
        "#{title} #{explanation}"
      else
        opts = []
        options.each_with_index do |opt,idx|
          if opt.is_a?(Array)
            opts << "#{opt[1].presence || OptionsIndices[idx]}-#{opt[0]}"
          else
            opts << "#{OptionsIndices[idx]}-#{opt}"
          end
        end
        "#{title} #{opts.join(' ')}"
      end
    end
  end

  def option_for(value)
    normalised_value = value.to_s.strip.downcase

    keys = OptionsIndices[0...options.count]
    options = self.options.clone
    options.each_with_index do |opt, index|
      if opt.is_a?(Array)
        keys[index] = opt[1]
        options[index] = opt[0]
      end
    end

    if keys.include?(normalised_value)
      options[keys.index(normalised_value)]
    elsif options.collect { |opt| opt.downcase }.include?(normalised_value)
      pos = options.collect { |opt| opt.downcase }.index(normalised_value)
      options[pos]
    elsif options.collect.with_index { |opt,i| "#{keys[i]}-#{opt.downcase}"}.include?(normalised_value)
      options[keys.index(normalised_value.split('-').first)]
    else
      nil
    end
  end

  def next_question(answer=nil)
    if answer && kind == :numeric
      num = answer.to_i

      cases = next_question_definition['cases']
      if cases
        cases.each do |a_case|
          case_min = a_case['min'].try(&:to_i) || -Float::INFINITY
          case_max = a_case['max'].try(&:to_i) || Float::INFINITY
          case_next = a_case['next']

          if case_min <= num && num <= case_max
            return self.poll.questions.where(position: case_next).first
          end
        end
      end
    end

    if next_pos = next_question_definition['next']
      self.poll.questions.where(position: next_pos).first
    elsif answer && (kind != :numeric) && (cases = next_question_definition['case']) && (next_pos = cases[answer])
      self.poll.questions.where(position: next_pos).first
    else
      self.next
    end
  end

  def next_question_definition=(value)
    value = JSON.parse(value) if value.kind_of?(String)
    super(value)
  end

  def kind_has_options?
    return kind_options?
  end

  def kind_valid?
    kind && !kind_unsupported?
  end

  def custom_message(key)
    custom_messages.try(:[], key).presence
  end

  %w(empty invalid_length doesnt_contain not_a_number number_not_in_range not_an_option options_explanation).each do |key|
    class_eval <<-CODE, __FILE__, __LINE__
      def custom_message_#{key}
        custom_message "#{key}"
      end

      def custom_message_#{key}=(value)
        set_custom_message "#{key}", value
      end
    CODE
  end

  def set_custom_message(key, value)
    self.custom_messages ||= {}
    self.custom_messages[key] = value.strip
    custom_messages_will_change!
  end

  private

  def kind_supported
    errors.add(:kind, _("is not supported")) if kind_unsupported?
  end

  def touch_user_lifespan
    Telemetry::Lifespan.touch_user(self.poll.try(:owner))
  end

  def merge_options_and_keys
    return unless keys && keys.any?(&:present?)

    self.options = self.options.zip(self.keys)
  end

end
