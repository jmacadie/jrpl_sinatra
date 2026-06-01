ENV['APP_ENV'] = 'test'

require 'minitest/autorun'

require_relative '../../app/application'
require_relative 'simplecov'
require_relative 'integration_methods'
require_relative 'email_methods'
