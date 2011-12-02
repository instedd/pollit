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