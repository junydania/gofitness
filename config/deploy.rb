# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

# load 'lib/capistrano/tasks/seed'

set :application, "gofitness"
set :repo_url, 'https://github.com/junydania/gofitness.git'
set :use_sudo, true
set :user,            'gofitnessadmin'
set :puma_threads,    [4, 16]
set :puma_workers,    0
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system node_modules}
# set :linked_files, %w{ config/application.yml }
set :pty, true

set :format, :pretty
set :assets_prefix, 'prepackaged-assets'
set :assets_manifests, ['app/assets/config/manifest.js']
set :rails_assets_groups, :assets
set :port, 7872

# Define roles, user and IP address of deployment server
# role :name, %{[user]@[IP adde.]}

set :pty,             true
set :use_sudo,        true
set :stages,          %w(production staging)
set :default_stage,   "staging"

set :rails_env,       :production
set :branch,          "change-servers"
set :deploy_via,      :remote_cache
set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :ssh_options, {
    forward_agent: true,
    port: 7872,
    auth_methods: %w[publickey],
    keys: %w(~/.ssh/gofitness-dev-key),
    user: fetch(:user)
}
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to true if using ActiveRecord
set :puma_restart_command, 'bundle exec puma'



# SSH Options
# See the example commented out section in the file
# for more options.

namespace :puma do
    desc 'Create Directories for Puma Pids and Socket'
    task :make_dirs do
      on roles(:app) do
        execute "mkdir #{shared_path}/tmp/sockets -p"
        execute "mkdir #{shared_path}/tmp/pids -p"
      end
    end

    before :start,     :make_dirs
end
  
namespace :deploy do
    desc "Make sure local git is in sync with remote."
    task :check_revision do
      on roles(:app) do
        unless `git rev-parse HEAD` == `git rev-parse origin/develop`
          puts "WARNING: HEAD is not the same as origin/develop"
          puts "Run `git push` to sync changes."
          exit
        end
      end
    end
  
    desc 'Initial Deploy'
    task :initial do
      on roles(:app) do
        before 'deploy:restart', 'puma:start'
        invoke 'deploy'
      end
    end
  
    desc 'Restart application'
    task :restart do
      on roles(:app), in: :sequence, wait: 5 do
        invoke 'puma:restart'
      end
    end

    desc 'Run npm:install'
    task :npm_install do
      on roles(:app) do
        within release_path do
          execute("cd #{release_path} && npm install")
        end
      end
    end

    # before :starting,   :check_revision
    before :compile_assets, :npm_install
    after  :finishing,  :compile_assets
    after  :finishing,  :cleanup
    after  :finishing,  :restart 

end
  
