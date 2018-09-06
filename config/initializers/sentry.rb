Raven.configure do |config|
    config.dsn = 'https://5bdee660fbb9448595e0806d800cafd4:66f3be52ec05485585ba417ae6228109@sentry.io/1273216'
    config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
    config.release = APP_VERSION
end