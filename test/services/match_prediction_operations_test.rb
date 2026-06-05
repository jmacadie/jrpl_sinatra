require_relative '../helpers/test_helpers'

class MatchPredictionOperationsTest < Minitest::Test
  def test_delegates_match_prediction_operations_to_explicit_collaborators
    operations, match_repository, prediction_repository = build_operations

    assert_equal({ match_id: 6 }, operations.load_match(4, 6))
    operations.add_prediction(4, 6, 2, 3)

    assert_equal [
      [:load_single_match, 4, 6]
    ], match_repository.calls
    assert_equal [
      [:add_prediction, 4, 6, 2, 3]
    ], prediction_repository.calls
  end

  def build_operations
    match_repository = FakeMatchRepository.new
    prediction_repository = FakePredictionRepository.new
    [
      MatchPredictionOperations.new(
        match_repository:,
        prediction_repository:
      ),
      match_repository,
      prediction_repository
    ]
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
  end

  class FakePredictionRepository
    attr_reader :calls

    def initialize
      @calls = []
    end

    def add_prediction(user_id, match_id, home_prediction, away_prediction)
      calls << [
        :add_prediction,
        user_id,
        match_id,
        home_prediction,
        away_prediction
      ]
    end
  end
end
