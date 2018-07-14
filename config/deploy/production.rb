set :rails_env, "production"  # tell cap to run migrations using production env

# role :app, %w{gofitnessadmin@178.128.181.200}
# role :web, %w{gofitnessadmin@178.128.181.200}
# role :db,  %w{gofitnessadmin@178.128.181.200}

set :migration_role, :app

# Defaults to the primary :db server
# set :migration_servers, -> { primary(fetch(:migration_role)) }

# Define server(s)
server '178.128.181.200', user: 'gofitnessadmin', roles: %w{web app db}, port: 7872, primary: true

