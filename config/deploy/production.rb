set :branch, "master"
set :deploy_user, 'ec2-user'
set :force_local_version_matches_deployed, true
set :concurrency, "puma=1,delayed=1,hub=1"

server 'pollit.instedd.org', user: fetch(:deploy_user), roles: %w{app web db}
