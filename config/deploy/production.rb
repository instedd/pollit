set :branch, "stable"
set :deploy_user, 'ec2-user'
set :force_local_version_matches_deployed, true
server 'pollit.instedd.org', user: fetch(:deploy_user), roles: %w{app web}
