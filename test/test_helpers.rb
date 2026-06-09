ENV['APP_ENV'] = 'test'

require 'minitest/autorun'

require_relative '../app/application'
require_relative 'helpers/simplecov'
require_relative 'helpers/integration_methods'
require_relative 'helpers/email_methods'
