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

  config.before(:each) do 
    Sham.reset

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
