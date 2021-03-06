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

class User < ActiveRecord::Base
  has_many :polls, :foreign_key => 'owner_id'
  has_many :channels, :foreign_key => 'owner_id'

  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :trackable, :validatable, :confirmable, :omniauthable

  attr_accessible :email, :password, :password_confirmation,
                  :remember_me, :name, :google_token

  has_many :identities, dependent: :destroy

  after_save :touch_lifespan
  after_destroy :touch_lifespan

  private

  def touch_lifespan
    Telemetry::Lifespan.touch_user(self)
  end
end
