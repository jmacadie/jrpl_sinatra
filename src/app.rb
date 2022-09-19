require 'bcrypt'
require 'pry'
require 'securerandom'
require 'sinatra'
require 'sinatra/cookies'
require 'tilt/erubis'

#class App < Sinatra::Base

  # Constant definitions
  LOCKDOWN_BUFFER = 30 * 60 # 30 minutes
  
  # Load database (model)
  require_relative 'db/database_persistence'

  # Load helpers
  require_relative 'helpers/loginable'
  require_relative 'helpers/login_cookies'
  require_relative 'helpers/route_errors'
  require_relative 'helpers/route_helpers'
  require_relative 'views/view_helpers'
  
  # Load controllers
  require_relative 'controllers/home'
  require_relative 'controllers/match'
  require_relative 'controllers/matches'
  require_relative 'controllers/tables'
  require_relative 'controllers/users'

  configure do
    enable :sessions
    set :session_secret, 'secret'
    set :erb, escape_html: true
  end

  configure :development do
    #require 'sinatra/reloader'
    #also_reload 'database_persistence.rb'
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
#end
