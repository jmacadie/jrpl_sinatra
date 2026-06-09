require "test_helpers"

class MatchTeamsTest < Minitest::Test
  def test_have_team_names
    match = {
      match_id: 63,
      home_name: 'Denmark',
      away_name: 'Sweden',
      home_tournament_role: 'Winner Semi-Final 1',
      away_tournament_role: 'Winner Semi-Final 2'
    }
    teams = Presenters::MatchTeams.new(match)
    assert_equal 'Denmark', teams.home_name
    assert_equal 'Sweden', teams.away_name
  end

  def test_empty_string_team_names
    match = {
      match_id: 63,
      home_name: '',
      away_name: '',
      home_tournament_role: 'Winner Semi-Final 1',
      away_tournament_role: 'Winner Semi-Final 2'
    }
    teams = Presenters::MatchTeams.new(match)
    assert_equal '', teams.home_name
    assert_equal '', teams.away_name
  end

  def test_nil_team_names
    match = {
      match_id: 63,
      home_name: nil,
      away_name: nil,
      home_tournament_role: 'Winner Semi-Final 1',
      away_tournament_role: 'Winner Semi-Final 2'
    }
    teams = Presenters::MatchTeams.new(match)
    assert_equal 'Winner Semi-Final 1', teams.home_name
    assert_equal 'Winner Semi-Final 2', teams.away_name
  end

  def test_missing_team_names
    match = {
      match_id: 63,
      home_tournament_role: 'Winner Semi-Final 1',
      away_tournament_role: 'Winner Semi-Final 2'
    }
    teams = Presenters::MatchTeams.new(match)
    assert_equal 'Winner Semi-Final 1', teams.home_name
    assert_equal 'Winner Semi-Final 2', teams.away_name
  end

  def test_missing_tournament_roles
    match = {
      match_id: 63,
      home_name: 'Denmark',
      away_name: 'Sweden'
    }
    teams = Presenters::MatchTeams.new(match)
    assert_equal 'Denmark', teams.home_name
    assert_equal 'Sweden', teams.away_name
  end

  def test_mixed_team_names
    match = {
      match_id: 63,
      home_name: 'Denmark',
      away_name: nil,
      home_tournament_role: 'Winner Semi-Final 1',
      away_tournament_role: 'Winner Semi-Final 2'
    }
    teams = Presenters::MatchTeams.new(match)
    assert_equal 'Denmark', teams.home_name
    assert_equal 'Winner Semi-Final 2', teams.away_name
  end
end
