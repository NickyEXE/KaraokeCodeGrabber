require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module KaraokeCable
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    config.api_only = true
    config.debug_exception_response_format = :api
    config.middleware.use Rack::Cors do
      allow do
        origins '*'
        resource '/*', :headers => :any, :methods => :any
      end
    end
    # RSpotify.authenticate(ENV['SPOTIFYCLIENTID'], ENV['SPOTIFYCLIENTSECRET'])
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
