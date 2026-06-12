require 'test_helpers'

class TournamentRoleRepositoryTest < Minitest::Test
  def setup
    @query_runner = FakeQueryRunner.new(rows: database_rows)
    repository = Repositories::TournamentRole.new(query_runner: @query_runner)
    @rows = repository.load_role_rows
  end

  def test_loads_flat_role_rows
    assert_equal expected_rows, @rows
  end

  def test_queries_tournament_roles_in_stage_and_role_order
    assert_equal 1, @query_runner.calls.size
    assert_includes @query_runner.calls[0], 'WHERE tr.stage_id > 1'
    assert_includes @query_runner.calls[0],
                    'ORDER BY s.stage_id, tr.tournament_role_id'
  end

  private

  def database_rows
    [
      {
        'stage' => 'Round of 16',
        'tournament_role' => 'Winner Group A',
        'tournament_role_id' => '25',
        'selected_team_id' => nil,
        'team_id' => '4',
        'team' => 'Switzerland'
      }
    ]
  end

  def expected_rows
    [
      {
        stage: 'Round of 16',
        role: 'Winner Group A',
        id: '25',
        selected_team_id: nil,
        team_id: '4',
        team: 'Switzerland'
      }
    ]
  end

  class FakeQueryRunner
    attr_reader :calls

    def initialize(rows:)
      @rows = rows
      @calls = []
    end

    def run_query(statement)
      calls << statement
      @rows
    end
  end
end
