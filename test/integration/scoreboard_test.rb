require_relative '../helpers/test_helpers'

class CMSTest < Minitest::Test
  include TestIntegrationMethods

  def test_scoreboard
    get '/scoreboard'

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Scoreboard'
    assert_includes body_html, '<td>Clare Mac</td> <td>1</td> <td>2</td> <td>3</td>'
  end

  def test_scoreboard_change_result
    post '/match/add_result',
          { match_id: 7, home_pts: '2', away_pts: '1' },
          admin_session
    get '/scoreboard'

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Scoreboard'
    assert_includes body_html, '<td>Mr. Mean</td> <td>1</td> <td>2</td> <td>3</td>'
    refute_includes body_html, '<td>Clare Mac</td> <td>1</td> <td>2</td> <td>3</td>'
  end

  def test_scoreboard_add_result
    post '/match/add_result',
          { match_id: 6, home_pts: '2', away_pts: '1' },
          admin_session
    get '/scoreboard'

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Scoreboard'
    assert_includes body_html, '<td>Clare Mac</td> <td>1</td> <td>2</td> <td>3</td>'
    assert_includes body_html, '<td>Mr. Median</td> <td>1</td> <td>2</td> <td>3</td>'
    assert_includes body_html, '<td>Maccas</td> <td>1</td> <td>0</td> <td>1</td>'
  end

  def test_autoquiz_scoreboard
    get '/toggle_scoring_system',
        { scoring_system: 'autoquiz' },
        non_admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Scoreboard'
    assert_includes body_html, '<td>Clare Mac</td> <td>2</td> <td>4</td> <td>6</td>'
    refute_includes body_html, '<td>Mr. Median</td> <td>2</td> <td>4</td> <td>6</td>'
  end

  def test_autoquiz_scoreboard_add_result
    post '/match/add_result',
          { match_id: 6, home_pts: '2', away_pts: '1' },
          admin_session
    get '/toggle_scoring_system',
        { scoring_system: 'autoquiz' },
        non_admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Scoreboard'
    assert_includes body_html, '<td>Clare Mac</td> <td>2</td> <td>4</td> <td>6</td>'
    assert_includes body_html, '<td>Mr. Median</td> <td>2</td> <td>4</td> <td>6</td>'
  end
end
