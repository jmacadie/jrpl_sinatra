ENV['APP_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'simplecov'
require 'stringio'

require_relative '../src/app'
require_relative 'jrpl_test_administer_accounts'
require_relative 'jrpl_test_carousel'
require_relative 'jrpl_test_email'
require_relative 'jrpl_test_login'
require_relative 'jrpl_test_matches_all'
require_relative 'jrpl_test_matches_filter'
require_relative 'jrpl_test_predictions'
require_relative 'jrpl_test_results'
require_relative 'jrpl_test_scoreboard'
require_relative 'jrpl_test_user_account'
require_relative 'jrpl_test_view_match'

SimpleCov.start

class CMSTest < Minitest::Test
  include Rack::Test::Methods
  include TestAdministerAccounts
  include TestCarousel
  include TestEmail
  include TestLogin
  include TestMatchesAll
  include TestMatchesFilter
  include TestPredictions
  include TestResults
  include TestScoreboard
  include TestUserAccount
  include TestViewMatch

  def app
    App
  end

  def setup
    sql = File.read('test/test_data.sql')
    $stderr.reopen("/dev/null", "w")
    $stderr.sync = true
    PG.connect(dbname: 'jrpl_test').exec(sql)
  end

  def teardown
    $stderr = STDERR
  end

  def session
    last_request.env['rack.session']
  end

  def body_text
    last_response.body
      .gsub(/\s/, ' ')
      .gsub(/<[^>]*>/, ' ')
      .squeeze(' ')
  end

  def admin_session
    { 'rack.session' => {
      user_name: 'Maccas',
      user_id: 4,
      user_email: 'james.macadie@telerealtrillium.com',
      user_roles: 'Admin'
    } }
  end

  def user_11_session
    { 'rack.session' => {
      user_name: 'Clare Mac',
      user_id: 11,
      user_email: 'clare@macadie.co.uk'
    } }
  end

  def nil_session
    { 'rack.session' => {
      user_name: nil,
      user_id: nil,
      user_email: nil
    } }
  end

  def user_11_session_with_all_criteria
    { 'rack.session' => {
      user_name: 'Clare Mac',
      user_id: 11,
      user_email: 'clare@macadie.co.uk',
      criteria: {
        match_status: "all",
        prediction_status: "all",
        tournament_stages:
          ["Group Stages",
           "Round of 16",
           "Quarter Finals",
           "Semi Finals",
           "Third Fourth Place Play-off",
           "Final"]
      }
    } }
  end

  def user_11_session_predicted_criteria
    { 'rack.session' => {
      user_name: 'Clare Mac',
      user_id: 11,
      user_email: 'clare@macadie.co.uk',
      criteria: {
        match_status: "all",
        prediction_status: "predicted",
        tournament_stages:
          ["Group Stages",
           "Round of 16",
           "Quarter Finals",
           "Semi Finals",
           "Third Fourth Place Play-off",
           "Final"]
      }
    } }
  end

  def user_11_session_not_predicted_group_stages_criteria
    { 'rack.session' => {
      user_name: 'Clare Mac',
      user_id: 11,
      user_email: 'clare@macadie.co.uk',
      criteria: {
        match_status: "all",
        prediction_status: "not_predicted",
        tournament_stages: ["Group Stages"]
      }
    } }
  end

  def admin_session_with_all_criteria
    { 'rack.session' => {
      user_name: 'Maccas',
      user_id: 4,
      user_email: 'james.macadie@telerealtrillium.com',
      user_roles: 'Admin',
      criteria: {
        match_status: "all",
        prediction_status: "all",
        tournament_stages:
          ["Group Stages",
           "Round of 16",
           "Quarter Finals",
           "Semi Finals",
           "Third Fourth Place Play-off",
           "Final"]
      }
    } }
  end

  def test_homepage_signed_out
    get '/'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'JRPL'
    refute_includes body_text, 'Edit Details'
    refute_includes body_text, 'Admin'
  end

  def test_homepage_signed_in
    get '/', {}, user_11_session
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'JRPL'
    assert_includes body_text, 'Edit Details'
    refute_includes body_text, 'Admin'
  end

  def test_homepage_signed_in_admin
    get '/', {}, admin_session
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'JRPL'
    assert_includes body_text, 'Edit Details'
    assert_includes body_text, 'Admin'
  end
end
