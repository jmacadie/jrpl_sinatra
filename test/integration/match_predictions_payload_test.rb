require 'json'
require "test_helpers"

class MatchPredictionsPayloadIntegrationTest < Minitest::Test
  include TestIntegrationMethods

  def test_locked_down_match_predictions_payload
    get '/match/1/predictions', {}, non_admin_session

    assert_equal 200, last_response.status
    assert_equal 'application/json', last_response['Content-Type']

    payload = response_payload
    assert_equal 'Germany', payload.fetch('match').fetch('home_name')
    assert_equal 'Scotland', payload.fetch('match').fetch('away_name')
    refute_empty payload.fetch('predictions')
  end

  private

  def response_payload
    JSON.parse(last_response.body)
  end
end
