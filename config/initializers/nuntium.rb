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

class Nuntium
  Config = YAML.load_file(File.expand_path('../../../config/nuntium.yml', __FILE__))[Rails.env] rescue nil

  def self.new_from_config
    Nuntium.new Config['url'], Config['account'], Config['application'], Config['password']
  end

  def self.config
    Config
  end

  def self.authenticate_at_post(user, pass)
    Config['at_post_user'] == user && Config['at_post_pass'] == pass
  end

end
