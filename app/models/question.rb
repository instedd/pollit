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

  belongs_to :poll
  has_many :answers

  validates :title, :presence => true
  validates :field_name, :presence => true
  validates :position, :presence => true
  validates :options, :presence => true, :if => :kind_options?
  validates :message, :length => {:maximum => 140}
  
  validate  :kind_supported

  validates_numericality_of :numeric_min, :only_integer => true, :if => lambda{|q| q.kind_numeric? && q.numeric_min }
  validates_numericality_of :numeric_max, :only_integer => true, :if => lambda{|q| q.kind_numeric? && q.numeric_max }

  acts_as_list :scope => :poll
  serialize :options, Array
  enum_attr :kind, %w(^text options numeric unsupported)

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
    if OptionsIndices[0..options.count-1].include?(value.downcase)
      options[OptionsIndices.index(value.downcase)]
    elsif options.collect { |opt| opt.downcase }.include?(value.downcase)
      pos = options.collect { |opt| opt.downcase }.index(value.downcase)
      options[pos]
    elsif options.collect.with_index { |opt,i| "#{OptionsIndices[i]}-#{opt.downcase}"}.include?(value.downcase)
      options[OptionsIndices.index(value.downcase.split('-').first)]
    else
      nil
    end
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

end
