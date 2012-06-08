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

require 'mail'

Mail.defaults do
  retriever_method :pop3, { :address             => "pop.gmail.com",
                            :port                => 995,
                            :user_name           => 'testingstg@gmail.com',
                            :password            => '8c4mmha2',
                            :enable_ssl          => true }
end

module MailHelper
  def get_mail
    sleep 15
    internal_get_mail
  end

  def internal_get_mail
    mail = Mail.last
    mail = mail.first if mail.is_a? Array
    if mail
      if mail.html_part
        mail.html_part.body.to_s
      else
        mail.body.to_s
      end
    else
      nil
    end
  end
end
