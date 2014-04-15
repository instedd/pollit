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

ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)
require File.expand_path(File.dirname(__FILE__) + '/blueprints')

require 'rspec/rails'
require 'webmock/rspec'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

# Configure rspec
RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.render_views = true
  config.extend ControllerMacros, :type => :controller
  config.include IceCubeMacros
  config.include TimeMacros

  config.before(:each) do
    Nuntium.stubs(:new_from_config).returns(@nuntium = mock('nuntium'))
    @nuntium.stubs(:create_channel).returns({:address => ""})
    @nuntium.stubs(:update_channel)
    @nuntium.stubs(:delete_channel)

    @nuntium_ao_messages = []
    @nuntium.stubs(:send_ao).with do |args|
      @nuntium_ao_messages += args; true
    end.returns(true)
  end
end

# Configure webmock
WebMock.allow_net_connect!
class WebMock::RequestStub
  def to_return_file(file)
    self.to_return(:body => File.new("#{Rails.root}/spec/webmocks/#{file}"), :status => 200)
  end
end
