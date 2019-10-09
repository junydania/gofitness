set :rails_env, "staging"  # tell cap to run migrations using staging env

# role :app, %w{gofitnessadmin@35.193.80.247}
# role :web, %w{gofitnessadmin@35.193.80.247}
# role :db,  %w{gofitnessadmin@35.193.80.247}
set :host, '35.193.80.247'
set :key, %w(~/.ssh/gofitness_staging)

set :migration_role, :app
set :ssh_options, {
    forward_agent: true,
    port: 7872,
    auth_methods: %w[publickey],
    keys: %w(~/.ssh/gofitness_staging),
    user: fetch(:user)
}

# Defaults to the primary :db server
# set :migration_servers, -> { primary(fetch(:migration_role)) }

# Define server(s)
server '35.193.80.247', user: 'gofitnessadmin', roles: %w{app web db}, port: 7872, primary: true

