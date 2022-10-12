ENV['APP_ENV'] = 'test'

require 'minitest/autorun'

require_relative '../../src/app'
require_relative 'simplecov'
require_relative 'integration_methods'
