require 'json'
require_relative '../helpers/test_helpers'

class GraphsIntegrationTest < Minitest::Test
  include TestIntegrationMethods

  def test_graphs_page
    get '/graphs', {}, non_admin_session

    assert_equal 200, last_response.status
    assert_includes body_text, 'Graphs'
    assert_includes body_text, 'Maccas'
  end

  # rubocop: disable Metrics/AbcSize
  def test_graphs_data
    get '/graphs/data', {}, non_admin_session

    assert_equal 200, last_response.status
    assert_equal 'application/json', last_response['Content-Type']

    points = graphs_points

    assert_equal 'Germany vs Scotland', points.first.fetch('match')
    assert_equal 34, points.first.fetch('users').length
    assert_equal(Array.new(34, 0),
                 points.first['users'].map { |user| user['cum_points'] })
    assert_equal(Array.new(34, 0),
                 points.first['users'].map { |user| user['rel_points'] })
    assert_equal(Array.new(34, 1),
                 points.first['users'].map { |user| user['rank'] })
  end

  def test_graphs_data_after_post_result
    get '/match/2', {}, admin_session
    post '/match/add_result',
         { home_score: 1,
           away_score: 0,
           match_id: 2,
           authenticity_token: csrf_token },
         admin_session

    get '/graphs/data', {}, non_admin_session

    assert_equal 200, last_response.status
    assert_equal 'application/json', last_response['Content-Type']

    match = match_point_row('Hungary vs Switzerland')

    assert_equal 1, user_value(match, 'Tom Mac', 'cum_points')
    assert_equal 2, user_value(match, 'Tom Mac', 'rel_points')
    assert_equal 2, user_value(match, 'Tom Mac', 'rank')

    assert_equal 3, user_value(match, 'Uwe', 'cum_points')
    assert_equal 0, user_value(match, 'Uwe', 'rel_points')
    assert_equal 1, user_value(match, 'Uwe', 'rank')

    assert_equal 0, user_value(match, 'Maccas', 'cum_points')
    assert_equal 3, user_value(match, 'Maccas', 'rel_points')
    assert_equal 8, user_value(match, 'Maccas', 'rank')
  end
  # rubocop: enable Metrics/AbcSize

  private

  def graphs_points
    JSON.parse(last_response.body).fetch('points')
  end

  def match_point_row(match_name)
    graphs_points.find { |match| match['match'] == match_name }
  end

  def user_value(match, user_name, key)
    match.fetch('users')
         .find { |user| user['user_name'] == user_name }
         .fetch(key)
  end
end
