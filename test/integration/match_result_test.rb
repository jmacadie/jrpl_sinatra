require_relative '../helpers/test_helpers'

class CMSTest < Minitest::Test
  include TestIntegrationMethods

  def test_view_match_not_lockdown_not_admin
    get '/match/64', {}, non_admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    refute_includes body_html, '<tr> <th>Player</th> <th>Prediction</th> <th>Points</th> </tr>'
  end

  def test_view_match_not_lockdown_admin
    get '/match/64', {}, admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    refute_includes body_html, '<tr> <th>Player</th> <th>Prediction</th> <th>Points</th> </tr>'
  end

  def test_view_match_lockdown_no_result_not_admin
    get '/match/6', {}, non_admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_html, '<tr> <th>Player</th> <th>Prediction</th> <th>Points</th> </tr>'
    assert_includes body_html, '<tr> <td>Maccas</td> <td><strong>Tunisia Win</strong><br />82&nbsp;-&nbsp;81</td> <td>-</td> </tr>'
  end

  def test_view_match_lockdown_no_result_admin
    get '/match/6', {}, admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_html, '<tr> <th>Player</th> <th>Prediction</th> <th>Points</th> </tr>'
    assert_includes body_html, '<tr> <td>Maccas</td> <td><strong>Tunisia Win</strong><br />82&nbsp;-&nbsp;81</td> <td>-</td> </tr>'
  end

  def test_view_match_lockdown_no_result_post_correct_score
    post '/match/add_result',
          {home_score: 81, away_score: 82, match_id: 6},
          admin_session

    assert_equal 302, last_response.status

    get last_response['Location']
    assert_includes body_html, '<tr> <th>Player</th> <th>Prediction</th> <th>Points</th> </tr>'
    assert_includes body_html, '<tr> <td>Maccas</td> <td><strong>Tunisia Win</strong><br />82&nbsp;-&nbsp;81</td> <td>3</td> </tr>'
  end

  def test_view_match_lockdown_no_result_post_correct_result
    post '/match/add_result',
          {home_score: 1, away_score: 2, match_id: 6},
          admin_session

    assert_equal 302, last_response.status

    get last_response['Location']
    assert_includes body_html, '<tr> <th>Player</th> <th>Prediction</th> <th>Points</th> </tr>'
    assert_includes body_html, '<tr> <td>Maccas</td> <td><strong>Tunisia Win</strong><br />82&nbsp;-&nbsp;81</td> <td>1</td> </tr>'
  end

  def test_view_match_lockdown_no_result_post_incorrect_result
    post '/match/add_result',
          {home_score: 3, away_score: 2, match_id: 6},
          admin_session

    assert_equal 302, last_response.status

    get last_response['Location']
    assert_includes body_html, '<tr> <th>Player</th> <th>Prediction</th> <th>Points</th> </tr>'
    assert_includes body_html, '<tr> <td>Maccas</td> <td><strong>Tunisia Win</strong><br />82&nbsp;-&nbsp;81</td> <td>-</td> </tr>'
  end
end
