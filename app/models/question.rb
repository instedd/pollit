class Question < ActiveRecord::Base
  acts_as_list :scope => :poll

  OptionsIndices = Array('a'..'z')

  belongs_to :poll
  has_many :answers

  validates :title,   :presence => true
  validates :options, :presence => true, :if => :kind_options?
  validates :message, :length => {:maximum => 140}

  validates_numericality_of :numeric_min, :only_integer => true, :if => lambda{|q| q.kind_numeric? && q.numeric_min }
  validates_numericality_of :numeric_max, :only_integer => true, :if => lambda{|q| q.kind_numeric? && q.numeric_max }

  serialize :options, Array
  
  enum_attr :kind, %w(^text options numeric)

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

  def valid_option?(value)
    value.downcase!
    return true if OptionsIndices[0..options.count-1].include?(value)
    return true if options.collect { |opt| opt.downcase }.include?(value)
    return true if options.collect.with_index { |opt,i| "#{OptionsIndices[i]}-#{opt.downcase}"}.include?(value)
    false
  end
end
