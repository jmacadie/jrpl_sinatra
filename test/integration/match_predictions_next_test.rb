require_relative '../helpers/test_helpers'

class CMSTest < Minitest::Test
  include TestIntegrationMethods

  def test_add_prediction_no_move
    post '/match/add_prediction',
         { match_id: '12', home_team_prediction: '98', away_team_prediction: '99', next: 'false' },
         non_admin_session

    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal 'Prediction submitted', session[:message]

    get last_response['Location']
    assert_includes body_text, '98'
    assert_includes body_text, '99'
  end

  def test_add_prediction_move
    post '/match/add_prediction',
         {
          match_id: '12',
          home_team_prediction: '98',
          away_team_prediction: '99',
          next: 'true',
          ring: 'eJwzMDA0AKFkAwMjAA-LAng=' },
         non_admin_session

    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal 'Prediction submitted', session[:message]

    get last_response['Location']
    refute_includes body_text, '98'
    refute_includes body_text, '99'

    # TODO: test clicking  previous match link as well

    get 'match/12', {}, non_admin_session
    assert_includes body_text, '98'
    assert_includes body_text, '99'
  end
end
