# Define roles, user and IP address of deployment server
# role :name, %{[user]@[IP adde.]}

set :pty,             true
set :use_sudo,        true
set :stage,           :production
set :rails_env, :production
set :branch, "fix-browserify"
set :deploy_via,      :remote_cache
set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :ssh_options, {
    forward_agent: true,
    auth_methods: %w[publickey],
    keys: %w(~/.ssh/gofitness-ci-key),
    user: fetch(:user)
}
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to true if using ActiveRecord
set :puma_restart_command, 'bundle exec puma'


role :app, %w{deployer@206.189.27.129}
role :web, %w{deployer@206.189.27.129}
role :db,  %w{deployer@206.189.27.129}

set :migration_role, :app

# Defaults to the primary :db server
set :migration_servers, -> { primary(fetch(:migration_role)) }

# Define server(s)
server '206.189.27.129', user: 'railsdeploy', roles: %w{web}

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

    # desc 'Install node modules'
    # task :install_node_modules do
    #   on roles(:app) do
    #     within release_path do
    #       execute :npm, 'install', '-s'
    #     end
    #   end
    # end

    desc 'Install node modules'
    task :compile_node_modules do
      on roles(:app) do
          invoke 'rake npm:install:clean'
        end
      end
    end



    before :starting,   :check_revision
    before :deploy,   :compile_node_modules
    # after  :finishing,  :compile_assets
    after  :finishing,  :cleanup
    after  :finishing,  :restart 
end
  
