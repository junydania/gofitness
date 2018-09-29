set :rails_env, "production"  # tell cap to run migrations using production env

# role :app, %w{gofitnessadmin@209.97.186.174}
# role :web, %w{gofitnessadmin@209.97.186.174}
# role :db,  %w{gofitnessadmin@209.97.186.174}
set :host, '209.97.186.174'
set :key, %w(~/.ssh/gofitness-prod-ci-key)

set :migration_role, :app
set :ssh_options, {
    forward_agent: true,
    port: 7872,
    auth_methods: %w[publickey],
    keys: %w(~/.ssh/gofitness-prod-ci-key),
    user: fetch(:user)
}


# Defaults to the primary :db server
# set :migration_servers, -> { primary(fetch(:migration_role)) }

# Define server(s)
server '209.97.186.174', user: 'gofitnessadmin', roles: %w{web app db}, port: 7872, primary: true

