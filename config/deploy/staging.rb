set :rails_env, "staging"  # tell cap to run migrations using staging env

role :app, %w{gofitnessadmin@35.196.34.34}
# role :web, %w{gofitnessadmin@35.196.34.34}
# role :db,  %w{gofitnessadmin@35.196.34.34}

set :migration_role, :app

# Defaults to the primary :db server
set :migration_servers, -> { primary(fetch(:migration_role)) }

# Define server(s)
server '35.196.34.34', user: 'gofitnessadmin', roles: %w{app}, port: 7872, primary: true

