require File.expand_path('../../../spec_helper', __FILE__)

acceptance_test do
  poll = unique('poll')
  get "/"
  login_as "mmuller+4691@manas.com.ar", "123456789"
  create_poll :title => poll, :description => unique("Another poll for you")
  go_to_my_polls
  i_should_see poll
end
