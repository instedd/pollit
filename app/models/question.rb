class Question < ActiveRecord::Base
  belongs_to :poll

  enum_attr :kind, %w(^text option)
end
