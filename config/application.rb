require_relative 'boot'

require 'rails/all'
require_relative 'version'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Gofitness
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    config.active_record.default_timezone = :local

    config.filter_parameters << :password

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.eager_load_paths << "#{Rails.root}/lib/capistrano/tasks"
    config.eager_load_paths << "#{Rails.root}/lib/*"
    config.browserify_rails.commandline_options = "-t coffeeify --extension=\".js.coffee\""

    config.active_job.queue_adapter = :sidekiq

    config.cache_store = :redis_store, 'redis://localhost:6379/0/cache', { expires_in: 90.minutes }

    config.autoload_paths << Rails.root.join("lib")
    config.eager_load_paths << Rails.root.join("lib")
    
  end
end
