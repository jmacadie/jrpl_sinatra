require_relative '../helpers/test_helpers'

class CMSTest < Minitest::Test
  include TestIntegrationMethods

  def test_add_new_result
    post '/match/add_result',
          { match_id: '3', home_score: '98', away_score: '99' },
          admin_session

    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal 'Result submitted', session[:message]

    get last_response['Location']
    assert_includes body_text, '98'
    assert_includes body_text, '99'
  end

  def test_add_new_result_not_admin
    post '/match/add_result',
          { match_id: '3', home_score: '98', away_score: '99' },
          non_admin_session

    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal 'You must be an administrator to do that.', session[:message]

    get last_response['Location']
    refute_includes body_text, '98'
    refute_includes body_text, '99'
  end

  def test_change_result
    post '/match/add_result',
          { match_id: '2', home_score: '98', away_score: '99' },
          admin_session

    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal 'Result submitted', session[:message]

    get last_response['Location']
    assert_includes body_text, '98'
    assert_includes body_text, '99'

    post '/match/add_result',
          { match_id: '2', home_score: '101', away_score: '102' },
          admin_session

    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal 'Result submitted', session[:message]

    get last_response['Location']
    refute_includes body_text, '98'
    refute_includes body_text, '99'
    assert_includes body_text, '101'
    assert_includes body_text, '102'
  end

  def test_add_decimal_result
    post '/match/add_result',
          { match_id: '3', home_score: '2.3', away_score: '3' },
          admin_session_with_all_criteria

    assert_equal 422, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Match results must be integers.'
  end

  def test_add_negative_result
    post '/match/add_result',
          { match_id: 3, home_score: '-2', away_score: '3' },
          admin_session_with_all_criteria

    assert_equal 422, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Match results must be non-negative.'
  end

  def test_add_result_not_lockeddown_match
    post '/match/add_result',
          { match_id: '64', home_score: '2', away_score: '3' },
          admin_session_with_all_criteria

    assert_equal 422, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text,
                    'You cannot add or change the match result because this match has not yet been played.'
  end
end
