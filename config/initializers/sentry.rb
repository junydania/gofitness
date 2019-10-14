Raven.configure do |config|
    config.dsn = 'https://b48c4f7e4a134a81b4ddebb3925baf21:e0a51d15d3174a29ab748ecdd1fac7a7@sentry.io/1779100'
    config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
    config.release = APP_VERSION
end