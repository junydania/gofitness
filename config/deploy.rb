# config valid for current version and patch releases of Capistrano
lock "~> 3.10.2"

# load 'lib/capistrano/tasks/seed'

set :application, "gofitness"
set :repo_url, 'https://github.com/junydania/gofitness.git'
set :use_sudo, true
set :user,            'railsdeploy'
set :puma_threads,    [4, 16]
set :puma_workers,    0
# set :deploy_to, "/home/railsdeploy/apps/gofitness"
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system node_modules}
set :pty, true

set :format, :pretty
set :assets_prefix, 'prepackaged-assets'
set :assets_manifests, ['app/assets/config/manifest.js']
set :rails_assets_groups, :assets
