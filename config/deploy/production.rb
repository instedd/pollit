set :branch, "experimental/capistrano-3"
set :deploy_user, 'ec2-user'
set :force_local_version_matches_deployed, false
# set :passenger_restart_with_touch, true
# set :rvm_ruby_version, :default
server 'pollit.instedd.org', user: fetch(:deploy_user), roles: %w{app web}
