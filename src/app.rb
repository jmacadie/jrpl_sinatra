require 'bcrypt'
require 'securerandom'
require 'sinatra'
require 'sinatra/cookies'
require 'yaml'

class App < Sinatra::Application
  # Constant definitions
  LOCKDOWN_BUFFER = 30 * 60 # 30 minutes

  # Load database (model)
  require_relative 'db/database_persistence'

  # Load helpers
  require_relative 'helpers/auth'
  require_relative 'helpers/login_cookies'
  require_relative 'helpers/route_errors'
  require_relative 'helpers/route_helpers'
  require_relative 'helpers/view_helpers'

  # Load controllers
  require_relative 'controllers/home'
  require_relative 'controllers/match'
  require_relative 'controllers/matches'
  require_relative 'controllers/tables'
  require_relative 'controllers/users'

  configure do
    enable :sessions
    set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }
    set :erb           , escape_html: true

    set :environment   , ENV.fetch('APP_ENV', 'development')

    set :src           , File.expand_path(__dir__)
    set :root          , File.expand_path('..', settings.src)
    set :app_file      , File.expand_path(__FILE__)
    set :public_folder , settings.root + '/public'
    set :config        , settings.root + '/config'
    set :views         , settings.src + '/views'

    dbconf = YAML.load_file(settings.config + '/database.yml')
    set :dbconf        , dbconf[settings.environment]
  end

  configure :development do
    # require 'sinatra/reloader'
    # also_reload 'database_persistence.rb'
  end

  before do
    @storage = DatabasePersistence.new(logger)
  end

  after do
    @storage.disconnect
  end

  helpers do
    # Route helper methods
    include Loginable
    include LoginCookies
    include RouteErrors
    include RouteHelpers

    # View helper methods
    include ViewHelpers
  end
end
