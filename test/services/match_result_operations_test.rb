require_relative '../helpers/test_helpers'

class MatchResultOperationsTest < Minitest::Test
  def test_delegates_match_result_operations_to_explicit_collaborators
    operations, match_repository, scoreboard_service, result_mailer =
      build_operations

    assert_equal({ match_id: 6 }, operations.load_match(6))
    operations.add_result(6, 2, 3, 4)
    operations.update_scoreboard(6, 2, 3)
    operations.send_result_email(6)

    assert_equal [
      [:load_single_match, 1, 6],
      [:add_result, 6, 2, 3, 4]
    ], match_repository.calls
    assert_equal [
      [:update_scoreboard, 6, 2, 3]
    ], scoreboard_service.calls
    assert_equal [
      [:send_result_email, 6]
    ], result_mailer.calls
  end

  def build_operations
    match_repository = FakeMatchRepository.new
    scoreboard_service = FakeScoreboardService.new
    result_mailer = FakeResultMailer.new
    [
      MatchResultOperations.new(
        match_repository:,
        scoreboard_service:,
        result_mailer:
      ),
      match_repository,
      scoreboard_service,
      result_mailer
    ]
  end

  class FakeScoreboardService
    attr_reader :calls

    def initialize
      @calls = []
    end

    def update_scoreboard(match_id, home_score, away_score)
      calls << [:update_scoreboard, match_id, home_score, away_score]
    end
  end

  class FakeResultMailer
    attr_reader :calls

    def initialize
      @calls = []
    end

    def send_result_email(match_id)
      calls << [:send_result_email, match_id]
    end
  end

  class FakeMatchRepository
    attr_reader :calls

    def initialize
      @calls = []
    end

    def load_single_match(user_id, match_id)
      calls << [:load_single_match, user_id, match_id]
      { match_id: }
    end

    def add_result(match_id, home_score, away_score, user_id)
      calls << [:add_result, match_id, home_score, away_score, user_id]
    end
  end
end
