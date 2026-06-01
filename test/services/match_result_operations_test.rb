require_relative '../helpers/test_helpers'

class MatchResultOperationsTest < Minitest::Test
  def test_delegates_match_result_operations_to_app_context
    app_context = FakeAppContext.new
    operations = MatchResultOperations.new(app_context)
    match = { match_id: 6 }

    assert_equal match, operations.load_match(6)
    operations.add_result(6, 2, 3, 4)
    operations.update_scoreboard(6, 2, 3)
    operations.send_result_email(6)

    assert_equal [
      [:load_single_match, 1, 6],
      [:add_result, 6, 2, 3, 4],
      [:update_scoreboard, 6, 2, 3],
      [:send_result_email, 6]
    ], app_context.calls
  end

  class FakeAppContext
    attr_reader :calls

    def initialize
      @calls = []
    end

    private

    def load_single_match(user_id, match_id)
      calls << [:load_single_match, user_id, match_id]
      { match_id: }
    end

    def add_result(match_id, home_score, away_score, user_id)
      calls << [:add_result, match_id, home_score, away_score, user_id]
    end

    def update_scoreboard(match_id, home_score, away_score)
      calls << [:update_scoreboard, match_id, home_score, away_score]
    end

    def send_result_email(match_id)
      calls << [:send_result_email, match_id]
    end
  end
end
