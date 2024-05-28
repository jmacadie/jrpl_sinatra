require_relative '../helpers/test_helpers'

class CMSTest < Minitest::Test
  include TestIntegrationMethods

  def test_graphs_data
    get '/graphs', {}, non_admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']

    assert_includes body_html, "function initOverallPoints() {"
    assert_includes body_html,
                    "['Germany vs Scotland', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],"
    assert_includes body_html,
                    "['Hungary vs Switzerland', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],"
    assert_includes body_html,
                    "['Serbia vs England', 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],"
    assert_includes body_html,
                    "['Romania vs Ukraine', 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],"

    assert_includes body_html, "function initRelativePoints() {"
    assert_includes body_html,
                    "['Germany vs Scotland', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],"
    assert_includes body_html,
                    "['Hungary vs Switzerland', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],"
    assert_includes body_html,
                    "['Serbia vs England', 3, 3, 3, 2, 3, 3, 3, 3, 3, 3, 0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],"
    assert_includes body_html,
                    "['Romania vs Ukraine', 3, 3, 3, 2, 3, 3, 3, 3, 3, 3, 0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],"

    assert_includes body_html, "function initPosition() {"
    assert_includes body_html,
                    "['Germany vs Scotland', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],"
    assert_includes body_html,
                    "['Hungary vs Switzerland', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],"
    assert_includes body_html,
                    "['Serbia vs England', 3, 3, 3, 2, 3, 3, 3, 3, 3, 3, 1, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],"
    assert_includes body_html,
                    "['Romania vs Ukraine', 3, 3, 3, 2, 3, 3, 3, 3, 3, 3, 1, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],"
  end

  def test_graphs_data_after_post_result
    post '/match/add_result',
         { home_score: 1, away_score: 0, match_id: 2 },
         admin_session
    get '/graphs', {}, non_admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']

    assert_includes body_html, "function initOverallPoints() {"
    assert_includes body_html,
                    "['Germany vs Scotland', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],"
    assert_includes body_html,
                    "['Hungary vs Switzerland', 0, 1, 1, 0, 1, 0, 0, 1, 1, 3, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],"
    assert_includes body_html,
                    "['Serbia vs England', 0, 1, 1, 1, 1, 0, 0, 1, 1, 3, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],"
    assert_includes body_html,
                    "['Romania vs Ukraine', 0, 1, 1, 1, 1, 0, 0, 1, 1, 3, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],"

    assert_includes body_html, "function initRelativePoints() {"
    assert_includes body_html,
                    "['Germany vs Scotland', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],"
    assert_includes body_html,
                    "['Hungary vs Switzerland', 3, 2, 2, 3, 2, 3, 3, 2, 2, 0, 3, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],"
    assert_includes body_html,
                    "['Serbia vs England', 3, 2, 2, 2, 2, 3, 3, 2, 2, 0, 0, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],"
    assert_includes body_html,
                    "['Romania vs Ukraine', 3, 2, 2, 2, 2, 3, 3, 2, 2, 0, 0, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],"

    assert_includes body_html, "function initPosition() {"
    assert_includes body_html,
                    "['Germany vs Scotland', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],"
    assert_includes body_html,
                    "['Hungary vs Switzerland', 8, 2, 2, 8, 2, 8, 8, 2, 2, 1, 8, 2, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8],"
    assert_includes body_html,
                    "['Serbia vs England', 10, 3, 3, 3, 3, 10, 10, 3, 3, 1, 1, 3, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10],"
    assert_includes body_html,
                    "['Romania vs Ukraine', 10, 3, 3, 3, 3, 10, 10, 3, 3, 1, 1, 3, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10],"
  end
end
