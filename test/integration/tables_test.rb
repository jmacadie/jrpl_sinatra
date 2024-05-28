require_relative '../helpers/test_helpers'

class CMSTest < Minitest::Test
  include TestIntegrationMethods

  def test_scoreboard
    get '/tables'

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Tables'
    assert_includes body_text, 'Clare Mac 1 2 3'
    assert_includes body_text, 'Maccas 1 - 1'
    assert_includes body_text, 'Mr. Mean - - -'
  end

  def test_scoreboard_change_result
    post '/match/add_result',
         { match_id: 7, home_score: '4', away_score: '2' },
         admin_session
    get '/tables'

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Tables'
    assert_includes body_text, 'Clare Mac - - -'
    assert_includes body_text, 'Maccas 1 2 3'
    assert_includes body_text, 'Mr. Mean 1 - 1'
  end

  def test_scoreboard_add_result
    post '/match/add_result',
         { match_id: 6, home_score: '76', away_score: '77' },
         admin_session
    get '/tables'

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Tables'
    assert_includes body_text, 'Clare Mac 2 2 4'
    assert_includes body_text, 'Maccas 2 - 2'
    assert_includes body_text, 'Mr. Mean 1 2 3'
  end
end
