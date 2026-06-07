require 'bcrypt'
require 'pony'
require 'connection_pool'
require 'rack/protection'
require 'rack/session'
require 'securerandom'
require 'sinatra'
require 'sinatra/cookies'
require 'tilt/erubi'
require 'yaml'

require_relative 'configuration/application_services'

# Load application services before helpers and controllers
Dir["#{File.expand_path(__dir__)}/services/**/*.rb"].each do |file|
  require file
end

# Load up all helpers
Dir["#{File.expand_path(__dir__)}/helpers/**/*.rb"].each do |file|
  require file
end

# Load up all controllers
Dir["#{File.expand_path(__dir__)}/controllers/**/*.rb"].each do |file|
  require file
end

class App < Sinatra::Application
  # Constant definitions
  LOCKDOWN_BUFFER = 30 * 60 # 30 minutes

  helpers Loginable
  helpers LoginCookies
  helpers ViewHelpers

  configure do
    # rubocop:disable Layout/SpaceBeforeComma, Layout/ExtraSpacing
    enable :sessions
    set :erb           , escape_html: true
    use Rack::Protection::AuthenticityToken

    set :environment   , ENV.fetch('APP_ENV', 'development')

    set :app_dir       , File.expand_path(__dir__)
    set :root          , File.expand_path('..', settings.app_dir)
    set :app_file      , File.expand_path(__FILE__)
    set :public_folder , "#{settings.root}/public"
    set :config        , "#{settings.root}/config"
    set :views         , "#{settings.app_dir}/views"
    set :tests         , "#{settings.root}/test"
    # rubocop:enable Layout/SpaceBeforeComma, Layout/ExtraSpacing

    # Load general settings
    YAML.load_file("#{settings.config}/general.yml").each do |k, v|
      set k.to_sym, v
    end
  end

  configure :staging, :production do
    set :session_secret, ENV.fetch('SESSION_SECRET')

    conf = YAML.load_file("#{settings.config}/database.yml")
    set :db_pool, ConnectionPool.new(size: 5, timeout: 5) {
      QueryRunner.connect(conf[settings.environment])
    }
  end

  configure :development, :test do
    set :session_secret, SecureRandom.hex(64)

    conf = YAML.load_file("#{settings.config}/database.yml")
    set :db_pool, ConnectionPool.new(size: 1, timeout: 5) {
      QueryRunner.connect(conf[settings.environment])
    }
  end

  configure :development, :test, :staging do
    Pony.subject_prefix("#{settings.environment.to_s.upcase}: ")
  end

  configure :test do
    Pony.override_options = { via: :test }
  end

  configure do
    ApplicationServices.register(self)
  end

  before do
    settings.lockdown_service.call
  end
end
