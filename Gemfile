source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.6'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.12'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'less-rails', '~> 3.0.0'
gem 'therubyracer' 
gem 'bootstrap', '~> 4.1.1'
gem 'jquery-rails'
gem 'material_design_icons'
gem 'devise'
gem 'selectize-rails'
gem 'wicked', '~> 1.3.2'
gem 'gon'
gem 'paystack'
gem 'shrine'
gem "aws-sdk-s3"
gem "browserify-rails"
gem 'figaro'
gem 'sidekiq'
gem "sidekiq-cron"
gem 'sinatra', require: false
gem 'slim'
gem 'cancancan', '~> 2.0'
gem 'ransack'
gem 'filterrific'
gem 'will_paginate', '~> 3.1.0'
gem 'plutus', :git => 'git://github.com/junydania/plutus.git'
gem 'jquery-ui-rails'
gem 'kaminari'
gem "audited", "~> 4.7"
gem "receipts"
gem 'mailjet'
gem "sentry-raven"
gem "exception_handler", '~> 0.8.0.0'
gem 'redis'
gem 'redis-namespace'
gem 'redis-rails'
gem 'redis-rack-cache'
gem 'groupdate'
gem 'authtrail'
gem 'syslogger', '~> 1.6.0'
gem 'lograge', '~> 0.3.1'
gem 'will_paginate-bootstrap4'


# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development
group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'pry', '~> 0.12.2'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'launchy'
  gem 'foreman'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem "factory_bot_rails", "~> 4.0"
  gem 'coveralls', require: false
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'capistrano',         require: false
  gem 'capistrano-rvm',     require: false
  gem 'capistrano-rails',   require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano3-puma',   require: false
  gem 'capistrano-npm'
end


# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

