require 'test_helpers'

class CumulativePointsPresenterTest < Minitest::Test
  def test_handles_empty_input
    points = Presenters::CumulativePoints.new([]).grouped_points

    assert_empty points
  end

  def test_groups_one_match
    rows = [
      point_row(match_id: '1', match: 'Germany vs Scotland',
                user_id: '11', user_name: 'Maccas', cum_points: '3')
    ]
    points = present(rows)

    assert_equal(
      [{
        match_id: 1,
        match: 'Germany vs Scotland',
        users: [{
          user_id: 11,
          user_name: 'Maccas',
          cum_points: 3
        }]
      }],
      points
    )
  end

  def test_groups_multiple_matches_and_users
    points = present(multiple_point_rows)

    assert_equal(
      multiple_points_summary,
      points_summary(points)
    )
  end

  def test_preserves_match_and_user_ordering
    rows = [
      point_row(match_id: '2', match: 'Second', user_id: '12',
                user_name: 'Zulu', cum_points: '4'),
      point_row(match_id: '2', match: 'Second', user_id: '11',
                user_name: 'Alpha', cum_points: '2'),
      point_row(match_id: '1', match: 'First', user_id: '11',
                user_name: 'Alpha', cum_points: '1')
    ]
    points = present(rows)

    assert_equal ['Second', 'First'], match_names(points)
    assert_equal ['Zulu', 'Alpha'], user_names(points[0])
  end

  def test_converts_nil_and_blank_numbers_to_zero
    rows = [
      point_row(match_id: nil, match: nil, user_id: '',
                user_name: nil, cum_points: nil)
    ]
    points = present(rows)

    assert_equal(
      [{
        match_id: 0,
        match: nil,
        users: [{
          user_id: 0,
          user_name: nil,
          cum_points: 0
        }]
      }],
      points
    )
  end

  private

  def present(rows)
    Presenters::CumulativePoints.new(rows).grouped_points
  end

  def point_row(attributes)
    {
      match_id: attributes[:match_id],
      match: attributes[:match],
      user_id: attributes[:user_id],
      user_name: attributes[:user_name],
      cum_points: attributes[:cum_points]
    }
  end

  def multiple_point_rows
    [
      point_row(match_id: '1', match: 'Germany vs Scotland',
                user_id: '11', user_name: 'Maccas', cum_points: '1'),
      point_row(match_id: '1', match: 'Germany vs Scotland',
                user_id: '12', user_name: 'Clare Mac', cum_points: '3'),
      point_row(match_id: '2', match: 'Hungary vs Switzerland',
                user_id: '11', user_name: 'Maccas', cum_points: '2')
    ]
  end

  def multiple_points_summary
    [
      ['Germany vs Scotland', 'Hungary vs Switzerland'],
      ['Maccas', 'Clare Mac'],
      ['Maccas'],
      [1, 3],
      [2]
    ]
  end

  def points_summary(points)
    [
      match_names(points),
      user_names(points[0]),
      user_names(points[1]),
      cumulative_points(points[0]),
      cumulative_points(points[1])
    ]
  end

  def match_names(points)
    points.map { |point| point[:match] }
  end

  def user_names(point)
    point[:users].map { |user| user[:user_name] }
  end

  def cumulative_points(point)
    point[:users].map { |user| user[:cum_points] }
  end
end
