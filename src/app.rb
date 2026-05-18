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

# Load up all helpers first
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

  configure do
    # rubocop:disable Layout/SpaceBeforeComma, Layout/ExtraSpacing
    enable :sessions
    set :erb           , escape_html: true
    use Rack::Protection::AuthenticityToken

    set :environment   , ENV.fetch('APP_ENV', 'development')

    set :src           , File.expand_path(__dir__)
    set :root          , File.expand_path('..', settings.src)
    set :app_file      , File.expand_path(__FILE__)
    set :public_folder , "#{settings.root}/public"
    set :config        , "#{settings.root}/config"
    set :views         , "#{settings.src}/views"
    set :helpers       , "#{settings.src}/helpers"
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
      DatabaseHelpers.connect(conf[settings.environment])
    }
  end

  configure :development, :test do
    set :session_secret, SecureRandom.hex(64)

    conf = YAML.load_file("#{settings.config}/database.yml")
    set :db_pool, ConnectionPool.new(size: 1, timeout: 5) {
      DatabaseHelpers.connect(conf[settings.environment])
    }
  end

  configure :development, :test, :staging do
    Pony.subject_prefix("#{settings.environment.to_s.upcase}: ")
  end

  configure :test do
    Pony.override_options = { via: :test }
  end

  before do
    # Add in all the helper modules
    extend DatabaseHelpers
    extend Email
    extend Lockdown
    extend Loginable
    extend LoginCookies
    extend RouteErrors
    extend RouteHelpers
    extend MrMen
    extend Scoring
    extend ViewHelpers

    check_lockdown()
  end
end
