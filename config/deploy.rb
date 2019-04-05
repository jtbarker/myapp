require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'
require 'mina/whenever/tasks'
require 'mina/systemd'

set :domain, 'myapp'
set :deploy_to, '/home/myapp/apps/myapp'
set :repository, 'git@github.com:myapp/advicy.git'
set :branch, 'master'
set :rails_env, 'production'
set :user, 'myapp'

set :shared_dirs, fetch(:shared_dirs, []).push('tmp/pids', 'tmp/sockets')
set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/puma.rb', 'config/secrets.yml')

task :environment do
  invoke :'rbenv:load'
end

task setup: :environment do
  command %[mkdir -p "#{fetch(:shared_path)}/config"]
  command %[chmod g+rx,u+rwx "#{fetch(:shared_path)}/config"]

  comment %{Be sure to add 'database.yml', 'secrets.yml' and 'puma.rb' in '#{fetch(:shared_path)}/config/' directory}
end

desc "Deploys the current version to the server."
task deploy: :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      invoke :'systemctl:restart', 'advicy-puma'
      invoke :'systemctl:restart', 'advicy-bg-worker'
      invoke :'whenever:update'
    end
  end
end