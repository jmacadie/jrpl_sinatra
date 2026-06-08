require_relative '../helpers/test_helpers'

class MatchPredictionServiceTest < Minitest::Test
  def test_records_a_prediction
    match_repository,
      prediction_repository,
      lockdown_policy,
      service = build_service
    result = service.call(match_id: 6,
                          home_prediction: 81,
                          away_prediction: 82,
                          user_id: 4)

    assert_predicate result, :success?
    assert_equal 6, result.match_id
    assert_equal 81, result.home_prediction
    assert_equal 82, result.away_prediction
    assert_prediction_stored_calls(match_repository,
                                   prediction_repository,
                                   lockdown_policy)
  end

  def test_decimal_prediction_returns_failure_without_adding_prediction
    match_repository, _, _, service = build_service
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
    match_repository, _, _, service = build_service
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
    match_repository, _, _, service = build_service(locked_down: true)
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

  def assert_prediction_stored_calls(match_repository,
                                     prediction_repository,
                                     lockdown_policy)
    assert_equal [
      [:load_match, 6]
    ], match_repository.calls
    assert_equal [
      [:add_prediction, 4, 6, 81, 82]
    ], prediction_repository.calls
    assert_equal [
      [:locked_down, 6]
    ], lockdown_policy.calls
  end

  def build_service(locked_down: false)
    match_repository = FakeMatchRepository.new()
    prediction_repository = FakePredictionRepository.new()
    lockdown_policy = FakeLockdownPolicy.new(locked_down:)
    service = Services::MatchPrediction.new(
      match_repository:,
      prediction_repository:,
      lockdown_policy:
    )
    return match_repository, prediction_repository, lockdown_policy, service
  end

  class FakeMatchRepository
    attr_reader :calls

    def initialize
      @calls = []
    end

    def load_match(match_id)
      calls << [:load_match, match_id]
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

  class FakeLockdownPolicy
    attr_reader :calls

    def initialize(locked_down:)
      @calls = []
      @locked_down = locked_down
    end

    def locked_down?(match)
      calls << [:locked_down, match[:match_id]]
      @locked_down
    end
  end
end
