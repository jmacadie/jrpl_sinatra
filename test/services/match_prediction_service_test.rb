require_relative '../helpers/test_helpers'

class MatchPredictionServiceTest < Minitest::Test
  def test_records_a_prediction
    match_repository, prediction_repository, service = build_service()
    result = service.call(match_id: 6,
                          home_prediction: 81,
                          away_prediction: 82,
                          user_id: 4)

    assert_predicate result, :success?
    assert_equal 6, result.match_id
    assert_equal 81, result.home_prediction
    assert_equal 82, result.away_prediction
    assert_equal [
      [:load_match, 6]
    ], match_repository.calls
    assert_equal [
      [:add_prediction, 4, 6, 81, 82]
    ], prediction_repository.calls
  end

  def test_decimal_prediction_returns_failure_without_adding_prediction
    match_repository, _, service = build_service()
    result = service.call(match_id: 6,
                          home_prediction: '2.3',
                          away_prediction: '3',
                          user_id: 4)

    refute_predicate result, :success?
    assert_equal 'Your predictions must be integers.', result.message
    assert_equal '2.3', result.home_prediction
    assert_equal '3', result.away_prediction
    assert_equal [
      [:load_match, 6]
    ], match_repository.calls
  end

  def test_negative_prediction_returns_failure_without_adding_prediction
    match_repository, _, service = build_service()
    result = service.call(match_id: 6,
                          home_prediction: -2,
                          away_prediction: 3,
                          user_id: 4)

    refute_predicate result, :success?
    assert_equal 'Your predictions must be non-negative.', result.message
    assert_equal (-2), result.home_prediction
    assert_equal 3, result.away_prediction
    assert_equal [
      [:load_match, 6]
    ], match_repository.calls
  end

  def test_locked_down_match_returns_failure_without_adding_prediction
    match_repository, _, service = build_service(
      match: { match_datetime: Time.now - 60 }
    )
    result = service.call(match_id: 6,
                          home_prediction: 81,
                          away_prediction: 82,
                          user_id: 4)

    refute_predicate result, :success?
    assert_equal(
      'You cannot add or change your prediction because this match is ' \
      'already locked down!',
      result.message
    )
    assert_equal [
      [:load_match, 6]
    ], match_repository.calls
  end

  private

  def build_service(
    match: { match_datetime: Time.now + App::LOCKDOWN_BUFFER + 60 }
  )
    match_repository = FakeMatchRepository.new(match:)
    prediction_repository = FakePredictionRepository.new()
    service = MatchPredictionService.new(
      match_repository:,
      prediction_repository:
    )
    return match_repository, prediction_repository, service
  end

  class FakeMatchRepository
    attr_reader :calls

    def initialize(
      match: { match_datetime: Time.now + App::LOCKDOWN_BUFFER + 60 }
    )
      @match = match
      @calls = []
    end

    def load_match(match_id)
      calls << [:load_match, match_id]
      @match
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
