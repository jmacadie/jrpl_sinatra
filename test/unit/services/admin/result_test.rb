require "test_helpers"

class MatchResultServiceTest < Minitest::Test
  def test_records_a_result
    match_repository,
      scoreboard_service,
      result_mailer,
      lockdown_policy,
      service = build_service
    result = service.call(match_id: 6,
                          home_score: '101',
                          away_score: '102',
                          user_id: 4)

    assert_predicate result, :success?
    assert_equal 101, result.home_score
    assert_equal 102, result.away_score
    assert_recorded_result_calls(match_repository,
                                 scoreboard_service,
                                 result_mailer,
                                 lockdown_policy)
  end

  def test_updates_an_existing_result
    _, _, _, _, service = build_service
    result = service.call(match_id: 6,
                          home_score: '81',
                          away_score: '82',
                          user_id: 4)
    assert_predicate result, :success?
    assert_equal 81, result.home_score
    assert_equal 82, result.away_score

    result = service.call(match_id: 6,
                          home_score: '101',
                          away_score: '102',
                          user_id: 4)
    assert_predicate result, :success?
    assert_equal 101, result.home_score
    assert_equal 102, result.away_score
  end

  def test_decimal_result_returns_failure_without_applying_result
    match_repository, _, _, _, service = build_service
    result = service.call(match_id: 6,
                          home_score: '2.3',
                          away_score: '3',
                          user_id: 4)

    refute_predicate result, :success?
    assert_equal 'Match results must be integers.', result.message
    assert_equal 2.3, result.home_score
    assert_equal 3.0, result.away_score
    assert_equal [
      [:load_match, 6]
    ], match_repository.calls
  end

  def test_negative_result_returns_failure_without_applying_result
    match_repository, _, _, _, service = build_service
    result = service.call(match_id: 6,
                          home_score: '-2',
                          away_score: '3',
                          user_id: 4)

    refute_predicate result, :success?
    assert_equal 'Match results must be non-negative.', result.message
    assert_equal [
      [:load_match, 6]
    ], match_repository.calls
  end

  def test_unplayed_match_returns_failure_without_applying_result
    match_repository, _, _, _, service = build_service(locked_down: false)
    result = service.call(match_id: 6,
                          home_score: '81',
                          away_score: '82',
                          user_id: 4)

    refute_predicate result, :success?
    assert_equal(
      'You cannot add or change the match result because this match has ' \
      'not yet been played.',
      result.message
    )
    assert_equal [
      [:load_match, 6]
    ], match_repository.calls
  end

  private

  def assert_recorded_result_calls(match_repository, scoreboard_service,
                                   result_mailer, lockdown_policy)
    assert_equal [
      [:load_match, 6],
      [:add_result, 6, 101, 102, 4]
    ], match_repository.calls
    assert_equal [
      [:update, 6, 101, 102]
    ], scoreboard_service.calls
    assert_equal [
      [:call, 6]
    ], result_mailer.calls
    assert_equal [
      [:locked_down, 6]
    ], lockdown_policy.calls
  end

  def build_service(locked_down: true)
    match_repository = FakeMatchRepository.new()
    scoreboard_service = FakeScoreboardService.new()
    result_mailer = FakeResultMailer.new()
    lockdown_policy = FakeLockdownPolicy.new(locked_down:)
    service = Services::Admin::Result.new(
      match_repository:,
      scoreboard_service:,
      result_mailer:,
      lockdown_policy:
    )
    return match_repository,
      scoreboard_service,
      result_mailer,
      lockdown_policy,
      service
  end

  class FakeMatchRepository
    attr_reader :calls

    def initialize
      @calls = []
    end

    def load_match(match_id:)
      calls << [:load_match, match_id]
      { match_id: }
    end

    def add_result(match_id:, home_score:, away_score:, user_id:)
      calls << [:add_result, match_id, home_score, away_score, user_id]
    end
  end

  class FakeScoreboardService
    attr_reader :calls

    def initialize
      @calls = []
    end

    def update(match_id:, home_score:, away_score:)
      calls << [:update, match_id, home_score, away_score]
    end
  end

  class FakeResultMailer
    attr_reader :calls

    def initialize
      @calls = []
    end

    def call(match_id:)
      calls << [:call, match_id]
    end
  end

  class FakeLockdownPolicy
    attr_reader :calls

    def initialize(locked_down:)
      @calls = []
      @locked_down = locked_down
    end

    def locked_down?(match:)
      calls << [:locked_down, match[:match_id]]
      @locked_down
    end
  end
end
