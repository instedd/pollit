class Question < ActiveRecord::Base
  OptionsIndices = Array('a'..'z')

  belongs_to :poll

  validate :poll, :presence => true
  validate :title, :presence => true, :length => {:maximum => 140}
  validate :options, :presence => true, :if => :kind_options?

  serialize :options, Array
  
  enum_attr :kind, %w(^text options numeric)

  def to_message
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
end
