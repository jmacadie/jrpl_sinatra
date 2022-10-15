require 'rack/test'
require_relative 'sessions'

module TestIntegrationMethods
  include Rack::Test::Methods

  def setup
    refresh_test_db
  end

  def app
    App
  end

  def refresh_test_db
    sql = File.read("#{App.settings.root}/data/test_data.sql")
    $stderr.reopen("/dev/null", "w")
    $stderr.sync = true
    PG.connect(dbname: App.settings.dbconf['database']).exec(sql)
    $stderr = STDERR
  end

  def session
    last_request.env['rack.session']
  end

  def body_html
    last_response.body
      .gsub(/\s/, ' ')
      .squeeze(' ')
  end

  def body_text
    last_response.body
      .gsub(/\s/, ' ') # remove newlines, tabs etc
      .gsub(/<input[^>]*value="([0-9]*)">/, ' \1 ') # Convert inputs with a value to just thier value
      .gsub(/<[^>]*>/, ' ') # Remove all other tags
      .gsub(/&lt;/, '<')    # Switch out encoded symbol
      .gsub(/&gt;/, '>')    # Switch out encoded symbol
      .gsub(/&amp;/, '&')   # Switch out encoded symbol
      .gsub(/&pound;/, '£') # Switch out encoded symbol
      .squeeze(' ') # collapse out multiple spaces
  end
end
