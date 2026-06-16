require "test_helpers"

class MrMenServiceTest < Minitest::Test
  def test_adds_mean_median_and_mode_predictions
    repository = FakePredictionRepository.new(
      predictions: [
        { home_prediction: 1, away_prediction: 0 },
        { home_prediction: 2, away_prediction: 1 },
        { home_prediction: 2, away_prediction: 4 },
        { home_prediction: nil, away_prediction: nil }
      ]
    )
    service = Services::Core::MrMen.new(prediction_repository: repository)

    service.call(match_id: 7)

    assert_equal [
      [:get_predictions_results, 7],
      [:add_prediction, 1, 7, 2, 2],
      [:add_prediction, 2, 7, 2, 1],
      [:add_prediction, 3, 7, 2, 2]
    ], repository.calls
  end

  def test_uses_zero_when_there_are_no_predictions
    repository = FakePredictionRepository.new(predictions: [])
    service = Services::Core::MrMen.new(prediction_repository: repository)

    service.call(match_id: 8)

    assert_equal [
      [:get_predictions_results, 8],
      [:add_prediction, 1, 8, 0, 0],
      [:add_prediction, 2, 8, 0, 0],
      [:add_prediction, 3, 8, 0, 0]
    ], repository.calls
  end

  class FakePredictionRepository
    attr_reader :calls

    def initialize(predictions:)
      @predictions = predictions
      @calls = []
    end

    def get_predictions_results(match_id:)
      calls << [:get_predictions_results, match_id]
      @predictions
    end

    def add_prediction(user_id:, match_id:, home_score:, away_score:)
      calls << [
        :add_prediction,
        user_id,
        match_id,
        home_score,
        away_score
      ]
    end
  end
end
