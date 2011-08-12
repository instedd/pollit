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

  config.before(:each) do 
    Sham.reset
  end    
end

# Configure webmock
WebMock.allow_net_connect!
class WebMock::RequestStub
  def to_return_file(file)
    self.to_return(:body => File.new("#{Rails.root}/spec/webmocks/#{file}"), :status => 200)
  end
end
