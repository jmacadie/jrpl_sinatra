require_relative '../helpers/test_helpers'

class MatchPredictionServiceTest < Minitest::Test
  def test_records_a_prediction
    operations = FakeMatchPredictionOperations.new
    result = build_service(operations:).call

    assert_predicate result, :success?
    assert_equal 6, result.match_id
    assert_equal 81, result.home_prediction
    assert_equal 82, result.away_prediction
    assert_equal [
      [:load_match, 4, 6],
      [:add_prediction, 4, 6, 81, 82]
    ], operations.calls
  end

  def test_decimal_prediction_returns_failure_without_adding_prediction
    operations = FakeMatchPredictionOperations.new
    result = build_service(
      operations:,
      home_prediction: 2.3,
      away_prediction: 3.0
    ).call

    refute_predicate result, :success?
    assert_equal 'Your predictions must be integers.', result.message
    assert_equal 2.3, result.home_prediction
    assert_equal 3.0, result.away_prediction
    assert_equal [
      [:load_match, 4, 6]
    ], operations.calls
  end

  def test_negative_prediction_returns_failure_without_adding_prediction
    operations = FakeMatchPredictionOperations.new
    result = build_service(
      operations:,
      home_prediction: -2.0,
      away_prediction: 3.0
    ).call

    refute_predicate result, :success?
    assert_equal 'Your predictions must be non-negative.', result.message
    assert_equal [
      [:load_match, 4, 6]
    ], operations.calls
  end

  def test_locked_down_match_returns_failure_without_adding_prediction
    operations = FakeMatchPredictionOperations.new(
      match: { match_datetime: Time.now - 60 }
    )
    result = build_service(operations:).call

    refute_predicate result, :success?
    assert_equal(
      'You cannot add or change your prediction because this match is ' \
      'already locked down!',
      result.message
    )
    assert_equal [
      [:load_match, 4, 6]
    ], operations.calls
  end

  private

  def build_service(operations:, home_prediction: 81.0, away_prediction: 82.0)
    MatchPredictionService.new(
      match_id: 6,
      home_prediction:,
      away_prediction:,
      user_id: 4,
      operations:
    )
  end

  class FakeMatchPredictionOperations
    attr_reader :calls

    def initialize(
      match: { match_datetime: Time.now + App::LOCKDOWN_BUFFER + 60 }
    )
      @match = match
      @calls = []
    end

    def load_match(user_id, match_id)
      calls << [:load_match, user_id, match_id]
      @match
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
