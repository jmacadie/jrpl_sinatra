require_relative '../helpers/test_helpers'

class MatchPredictionsIntegrationTest < Minitest::Test
  include TestIntegrationMethods

  # rubocop: disable Metrics/AbcSize
  def test_add_new_prediction
    get '/match/12', {}, non_admin_session
    post '/match/add_prediction',
         { match_id: '12',
           home_team_prediction: '98',
           away_team_prediction: '99',
           authenticity_token: csrf_token }

    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal 'Prediction submitted', session[:message]

    get last_response['Location']
    assert_includes body_text, '98'
    assert_includes body_text, '99'
  end

  def test_change_prediction
    get '/match/11', {}, non_admin_session
    post '/match/add_prediction',
         { match_id: '11',
           home_team_prediction: '98',
           away_team_prediction: '99',
           authenticity_token: csrf_token }

    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal 'Prediction submitted', session[:message]

    get last_response['Location']
    assert_includes body_text, '98'
    assert_includes body_text, '99'
  end
  # rubocop: enable Metrics/AbcSize

  def test_add_decimal_prediction
    get '/match/11', {}, non_admin_session
    post '/match/add_prediction',
         { match_id: '11',
           home_team_prediction: '2.3',
           away_team_prediction: '3',
           authenticity_token: csrf_token }

    assert_equal 422, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Your predictions must be integers.'
  end

  def test_add_negative_prediction
    get '/match/11', {}, non_admin_session
    post '/match/add_prediction',
         { match_id: '11',
           home_team_prediction: '-2',
           away_team_prediction: '3',
           authenticity_token: csrf_token }

    assert_equal 422, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Your predictions must be non-negative.'
  end

  def test_add_prediction_lockeddown_match
    get '/match/1', {}, non_admin_session
    post '/match/add_prediction',
         { match_id: '1',
           home_team_prediction: '2',
           away_team_prediction: '3',
           authenticity_token: csrf_token }

    assert_equal 422, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text,
                    'You cannot add or change your prediction because this ' \
                    'match is already locked down!'
  end
end
