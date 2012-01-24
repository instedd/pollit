require 'bundler/capistrano'
require 'rvm/capistrano'
set :rvm_ruby_string, '1.9.3'

set :application, "pollit"
set :repository,  "https://bitbucket.org/instedd/pollit"
set :scm, :mercurial
set :deploy_via, :remote_cache
default_environment['TERM'] = ENV['TERM']

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :symlink_nuntium_config, :roles => :app do
    run "ln -nfs #{shared_path}/nuntium.yml #{release_path}/config/"
  end
end

before "deploy:start", "deploy:migrate"
before "deploy:restart", "deploy:migrate"
after "deploy:update_code", "deploy:symlink_nuntium_config"
