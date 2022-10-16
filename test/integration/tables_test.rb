require_relative '../helpers/test_helpers'

class CMSTest < Minitest::Test
  include TestIntegrationMethods

  def test_scoreboard
    get '/tables'

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Tables'
    assert_includes body_html, '<td>Clare Mac</td> <td>1</td> <td>2</td> <td>3</td>'
  end

  def test_scoreboard_change_result
    post '/match/add_result',
          { match_id: 7, home_score: '2', away_score: '1' },
          admin_session
    get '/tables'

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Tables'
    assert_includes body_html, '<td>Mr. Mean</td> <td>1</td> <td>2</td> <td>3</td>'
    refute_includes body_html, '<td>Clare Mac</td> <td>1</td> <td>2</td> <td>3</td>'
  end

  def test_scoreboard_add_result
    post '/match/add_result',
          { match_id: 6, home_score: '2', away_score: '1' },
          admin_session
    get '/tables'

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes body_text, 'Tables'
    assert_includes body_html, '<td>Clare Mac</td> <td>1</td> <td>2</td> <td>3</td>'
    assert_includes body_html, '<td>Mr. Median</td> <td>1</td> <td>2</td> <td>3</td>'
    assert_includes body_html, '<td>Maccas</td> <td>1</td> <td>0</td> <td>1</td>'
  end
end
