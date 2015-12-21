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

  enum_attr :kind, %w(^text options numeric unsupported)

  after_save :touch_user_lifespan
  after_destroy :touch_user_lifespan

  def message
    if kind_text?
      title
    elsif numeric?
      "#{title} #{numeric_min}-#{numeric_max}"
    elsif kind_options?
      opts = []
      options.each_with_index do |opt,idx|
        opts << "#{OptionsIndices[idx]}-#{opt}"
      end
      "#{title} #{opts.join(' ')}"
    end
  end

  def option_for(value)
    normalised_value = value.to_s.strip.downcase
    if OptionsIndices[0..options.count-1].include?(normalised_value)
      options[OptionsIndices.index(normalised_value)]
    elsif options.collect { |opt| opt.downcase }.include?(normalised_value)
      pos = options.collect { |opt| opt.downcase }.index(normalised_value)
      options[pos]
    elsif options.collect.with_index { |opt,i| "#{OptionsIndices[i]}-#{opt.downcase}"}.include?(normalised_value)
      options[OptionsIndices.index(normalised_value.split('-').first)]
    else
      nil
    end
  end

  def next_question(answer=nil)
    if next_pos = next_question_definition['next']
      self.poll.questions.where(position: next_pos).first
    elsif answer && (cases = next_question_definition['case']) && (next_pos = cases[answer])
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

  private

  def kind_supported
    errors.add(:kind, _("is not supported")) if kind_unsupported?
  end

  def touch_user_lifespan
    Telemetry::Lifespan.touch_user(self.poll.try(:owner))
  end

end
