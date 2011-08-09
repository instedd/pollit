class Question < ActiveRecord::Base
  belongs_to :poll

  validate :poll, :presence => true
  validate :title, :presence => true, :length => {:maximum => 140}
  validate :options, :presence => true, :if => :kind_options?

  serialize :options, Array
  enum_attr :kind, %w(^text options)
end
