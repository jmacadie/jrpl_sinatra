require 'bcrypt'
require 'pony'
require 'securerandom'
require 'sinatra'
require 'sinatra/cookies'
require 'tilt/erubis'
require 'yaml'

# Load up all helpers first
Dir["#{File.expand_path(__dir__)}/helpers/**/*.rb"].sort.each do |file|
  require file
end

# Load up all controllers
Dir["#{File.expand_path(__dir__)}/controllers/**/*.rb"].sort.each do |file|
  require file
end

# Load database (model)
require_relative 'db/database_persistence'

class App < Sinatra::Application
  # Constant definitions
  LOCKDOWN_BUFFER = 30 * 60 # 30 minutes

  configure do
    # rubocop:disable Layout/SpaceBeforeComma, Layout/ExtraSpacing
    enable :sessions
    set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }
    set :erb           , escape_html: true

    set :environment   , ENV.fetch('APP_ENV', 'development')

    set :src           , File.expand_path(__dir__)
    set :root          , File.expand_path('..', settings.src)
    set :app_file      , File.expand_path(__FILE__)
    set :public_folder , "#{settings.root}/public"
    set :config        , "#{settings.root}/config"
    set :views         , "#{settings.src}/views"
    set :helpers       , "#{settings.src}/helpers"
    set :tests         , "#{settings.root}/test"

    dbconf = YAML.load_file("#{settings.config}/database.yml")
    set :dbconf        , dbconf[settings.environment]
    # rubocop:enable Layout/SpaceBeforeComma, Layout/ExtraSpacing

    # Load general settings
    YAML.load_file("#{settings.config}/general.yml").each do |k, v|
      set k.to_sym, v
    end
  end

  configure :development, :test do
    # rubocop:disable Layout/LineLength
    set :session_secret, 'qwertyuiopasdfghjklzxcvbnmsssssssssssrpppppppppppppppppppppppppppppppppppppppppppppppp'
    # rubocop:enable Layout/LineLength
  end

  configure :development, :test, :staging do
    Pony.subject_prefix("#{settings.environment.to_s.upcase}: ")
  end

  configure :test do
    Pony.override_options = { via: :test }
  end

  before do
    # Add in all the helper modules
    extend Email
    extend Lockdown
    extend Loginable
    extend LoginCookies
    extend RouteErrors
    extend RouteHelpers
    extend MrMen
    extend Scoring
    extend ViewHelpers

    DatabasePersistence.create(logger, settings.dbconf)
    @storage = DatabasePersistence.new

    check_lockdown()
  end

  after do
    DatabasePersistence.disconnect
  end
end
