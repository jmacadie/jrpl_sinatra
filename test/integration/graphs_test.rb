require_relative '../helpers/test_helpers'

class CMSTest < Minitest::Test
  include TestIntegrationMethods

  def test_graphs_data
    get '/graphs', {}, non_admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']

    assert_includes body_html,
                    "var data = new google.visualization.DataTable(); data.addColumn('string', 'Match'); data.addColumn('number', 'Archie'); data.addColumn('number', 'Ben'); data.addColumn('number', 'Binary Boy'); data.addColumn('number', 'Clare Mac'); data.addColumn('number', 'Coups'); data.addColumn('number', 'David'); data.addColumn('number', 'Diego'); data.addColumn('number', 'DTM'); data.addColumn('number', 'Fi Mac'); data.addColumn('number', 'G.Mozz'); data.addColumn('number', 'galsnakes'); data.addColumn('number', 'Gen'); data.addColumn('number', 'Haller'); data.addColumn('number', 'Jonny'); data.addColumn('number', 'Kov'); data.addColumn('number', 'Lady Peck'); data.addColumn('number', 'Lottie'); data.addColumn('number', 'Maccas'); data.addColumn('number', 'Manon'); data.addColumn('number', 'Mark S'); data.addColumn('number', 'Matt'); data.addColumn('number', 'Mond'); data.addColumn('number', 'Mr. Mean'); data.addColumn('number', 'Mr. Median'); data.addColumn('number', 'Mr. Mode'); data.addColumn('number', 'Ollie'); data.addColumn('number', 'Peck'); data.addColumn('number', 'Rosa'); data.addColumn('number', 'Ross'); data.addColumn('number', 'Sammie'); data.addColumn('number', 'Sven'); data.addColumn('number', 'Tom Mac'); data.addColumn('number', 'Uwe'); data.addColumn('number', 'Will Mac');"

    assert_includes body_html, "function initOverallPoints() {"
    assert_includes body_html,
                    "['Germany vs Scotland', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],"
    assert_includes body_html,
                    "['Hungary vs Switzerland', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],"
    assert_includes body_html,
                    "['Serbia vs England', 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],"
    assert_includes body_html,
                    "['Romania vs Ukraine', 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],"

    assert_includes body_html, "function initRelativePoints() {"
    assert_includes body_html,
                    "['Germany vs Scotland', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],"
    assert_includes body_html,
                    "['Hungary vs Switzerland', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],"
    assert_includes body_html,
                    "['Serbia vs England', 3, 3, 3, 0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],"
    assert_includes body_html,
                    "['Romania vs Ukraine', 3, 3, 3, 0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],"

    assert_includes body_html, "function initPosition() {"
    assert_includes body_html,
                    "['Germany vs Scotland', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],"
    assert_includes body_html,
                    "['Hungary vs Switzerland', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],"
    assert_includes body_html,
                    "['Serbia vs England', 3, 3, 3, 1, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],"
    assert_includes body_html,
                    "['Romania vs Ukraine', 3, 3, 3, 1, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],"
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
                    "['Hungary vs Switzerland', 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 1, 3, 0],"
    assert_includes body_html,
                    "['Serbia vs England', 0, 0, 1, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 1, 3, 0],"
    assert_includes body_html,
                    "['Romania vs Ukraine', 0, 0, 1, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 1, 3, 0],"

    assert_includes body_html, "function initRelativePoints() {"
    assert_includes body_html,
                    "['Germany vs Scotland', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],"
    assert_includes body_html,
                    "['Hungary vs Switzerland', 3, 3, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 3, 3, 3, 3, 2, 3, 2, 0, 3],"
    assert_includes body_html,
                    "['Serbia vs England', 3, 3, 2, 0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 3, 3, 2, 3, 3, 3, 3, 3, 2, 2, 3, 3, 3, 3, 2, 3, 2, 0, 3],"
    assert_includes body_html,
                    "['Romania vs Ukraine', 3, 3, 2, 0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 3, 3, 2, 3, 3, 3, 3, 3, 2, 2, 3, 3, 3, 3, 2, 3, 2, 0, 3],"

    assert_includes body_html, "function initPosition() {"
    assert_includes body_html,
                    "['Germany vs Scotland', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],"
    assert_includes body_html,
                    "['Hungary vs Switzerland', 8, 8, 2, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 2, 8, 8, 8, 8, 8, 8, 8, 8, 2, 2, 8, 8, 8, 8, 2, 8, 2, 1, 8],"
    assert_includes body_html,
                    "['Serbia vs England', 10, 10, 3, 1, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 3, 10, 10, 3, 10, 10, 10, 10, 10, 3, 3, 10, 10, 10, 10, 3, 10, 3, 1, 10],"
    assert_includes body_html,
                    "['Romania vs Ukraine', 10, 10, 3, 1, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 3, 10, 10, 3, 10, 10, 10, 10, 10, 3, 3, 10, 10, 10, 10, 3, 10, 3, 1, 10],"
  end
end
