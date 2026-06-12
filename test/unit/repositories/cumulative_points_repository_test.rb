require 'test_helpers'

class CumulativePointsRepositoryTest < Minitest::Test
  def setup
    @query_runner = FakeQueryRunner.new(rows: database_rows)
    repository = Repositories::CumulativePoints.new(
      query_runner: @query_runner
    )
    @rows = repository.load_cumulative_point_rows
  end

  def test_loads_flat_cumulative_point_rows
    assert_equal expected_rows, @rows
  end

  def test_queries_points_in_match_and_user_order
    assert_equal 1, @query_runner.calls.size
    assert_includes @query_runner.calls[0],
                    'ORDER BY sm.match_sort, UPPER(u.user_name)'
  end

  private

  def database_rows
    [{
      'match_id' => '2',
      'match_desc' => 'Hungary vs Switzerland',
      'user_id' => '11',
      'user_name' => 'Maccas',
      'cum_points' => '3'
    }]
  end

  def expected_rows
    [{
      match_id: '2',
      match: 'Hungary vs Switzerland',
      user_id: '11',
      user_name: 'Maccas',
      cum_points: '3'
    }]
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
