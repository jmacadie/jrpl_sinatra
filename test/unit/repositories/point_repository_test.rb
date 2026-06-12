require 'test_helpers'

class PointRepositoryTest < Minitest::Test
  def setup
    @query_runner = FakeQueryRunner.new(results: scoreboard_results)
    repository = Repositories::Point.new(query_runner: @query_runner)
    @tables = repository.load_scoreboard_data('Official')
  end

  def test_loads_unranked_scoreboard_tables
    assert_equal(
      {
        overall_table: [scoreboard_hash('1', 'Clare Mac', 1, 2, 3)],
        group_table: [scoreboard_hash('2', 'Maccas', 1, 0, 1)],
        knockout_table: [scoreboard_hash('3', 'Mr. Mean', 0, 0, 0)]
      },
      @tables
    )
    refute(@tables.values.flatten.any? { |row| row.key?(:rank) })
  end

  def test_queries_each_scoreboard_with_the_scoring_system
    assert_equal ['Official'], @query_runner.calls[0][1..]
    assert_equal [1], @query_runner.calls[1][1..]
    assert_equal [1], @query_runner.calls[2][1..]
    assert_equal [1], @query_runner.calls[3][1..]
  end

  private

  def scoreboard_results
    [
      [{ 'scoring_system_id' => '1' }],
      [scoreboard_row('1', 'Clare Mac', '1', '2', '3')],
      [scoreboard_row('2', 'Maccas', '1', '0', '1')],
      [scoreboard_row('3', 'Mr. Mean', '0', '0', '0')]
    ]
  end

  def scoreboard_row(user_id, user_name, result_points, score_points,
                     total_points)
    {
      'user_id' => user_id,
      'user_name' => user_name,
      'result_points' => result_points,
      'score_points' => score_points,
      'total_points' => total_points
    }
  end

  def scoreboard_hash(user_id, user_name, result_points, score_points,
                      total_points)
    {
      user_id:,
      user_name:,
      result_points:,
      score_points:,
      total_points:
    }
  end

  class FakeQueryRunner
    attr_reader :calls

    def initialize(results:)
      @results = results
      @calls = []
    end

    def run_query(statement, *params)
      calls << [statement, *params]
      @results.shift
    end
  end
end
