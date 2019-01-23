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
module ApplicationHelper

  include Rgviz::ViewHelper

  def image_tag(source, options = {})
    source = File.join(I18n.locale.to_s, source) if options.delete(:localized)
    super(source, options)
  end

  def wizard?
    params[:wizard]
  end

  def instedd_theme_url_for(path)
    url = Settings.theme_url
    URI.join url, path
  end

  def file_form_for(record, options={}, &proc)
    options.merge!(:method => :post, :html => {:multipart => true})
    form_for(record, options, &proc)
  end

  def section title, url, name, active_controllers = [name]
    active = active_controllers.any?{|controller| controller_name == controller.to_s }
    raw "<li class=\"#{active ? "active" : ""}\">#{link_to title, url}</li>"
  end
end
