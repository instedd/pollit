# NB: Deploy to staging adding RVM=1 before the `cap deploy` command
set :branch, 'master'
set :deploy_user, 'ubuntu'
set :force_local_version_matches_deployed, true

set :rvm_type, :system
set :rvm_ruby_version, '2.0.0-p598'

set :concurrency, "puma=0,delayed=1,hub=1"

server 'pollit-stg.instedd.org', user: fetch(:deploy_user), roles: %w{app web db}
