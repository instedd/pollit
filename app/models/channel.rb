class Channel < ActiveRecord::Base
  belongs_to :user

  validates :user_id, :presence => true
  validates :name, :presence => true
  validates :address, :presence => true
end
