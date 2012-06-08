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

class ActionController::TestCase < ActiveSupport::TestCase
  module Behavior
    def process_with_default_params(action, parameters = nil, session = nil, flash = nil, http_method = 'GET')
      default_params = {:locale => :en}
      parameters ||= {}
      parameters.reverse_merge! default_params
      process_without_default_params(action, parameters, session, flash, http_method)
    end
    alias_method_chain :process, :default_params
  end
end