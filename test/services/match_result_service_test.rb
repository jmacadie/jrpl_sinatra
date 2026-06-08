require_relative '../helpers/test_helpers'

class MatchResultServiceTest < Minitest::Test
  def test_records_a_result
    match_repository, scoreboard_service, result_mailer, service = build_service
    result = service.call(match_id: 6,
                          home_score: '101',
                          away_score: '102',
                          user_id: 4)

    assert_predicate result, :success?
    assert_equal 101, result.home_score
    assert_equal 102, result.away_score
    assert_equal [
      [:load_match, 6],
      [:add_result, 6, 101, 102, 4]
    ], match_repository.calls
    assert_equal [
      [:update_scoreboard, 6, 101, 102]
    ], scoreboard_service.calls
    assert_equal [
      [:send_result_email, 6]
    ], result_mailer.calls
  end

  def test_updates_an_existing_result
    _, _, _, service = build_service
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
    match_repository, _, _, service = build_service
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
    match_repository, _, _, service = build_service
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
    match_repository, _, _, service = build_service(
      match: { match_datetime: Time.now + App::LOCKDOWN_BUFFER + 60 }
    )
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

  def build_service(match: { match_datetime: Time.now - 60 })
    match_repository = FakeMatchRepository.new(match:)
    scoreboard_service = FakeScoreboardService.new()
    result_mailer = FakeResultMailer.new()
    service = Services::MatchResult.new(
      match_repository:,
      scoreboard_service:,
      result_mailer:
    )
    return match_repository, scoreboard_service, result_mailer, service
  end

  class FakeMatchRepository
    attr_reader :calls

    def initialize(match:)
      @match = match
      @calls = []
    end

    def load_match(match_id)
      calls << [:load_match, match_id]
      @match
    end

    def add_result(match_id, home_score, away_score, user_id)
      calls << [:add_result, match_id, home_score, away_score, user_id]
    end
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
end
