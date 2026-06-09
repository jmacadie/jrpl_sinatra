require "test_helpers"

class MatchPageServiceTest < Minitest::Test
  def test_builds_page_data_for_unlocked_match
    match_repository, _, _, lockdown_policy, service = build_service(
      match: default_fixture
    )
    page = call_service(service:)

    assert_equal 6, page.match[:match_id]
    refute page.match[:locked_down]
    refute page.result
    assert_empty_optional_page_data(page)
    assert_equal [
      [:load_match, 4, 6]
    ], match_repository.calls
    assert_equal [
      [:locked_down, 6]
    ], lockdown_policy.calls
  end

  def test_builds_page_data_for_locked_down_match
    fixture = match_fixture(home_score: 2)
    match_repository,
      user_repository,
      predictions_repository,
      lockdown_policy,
      service =
      build_service(match: fixture, locked_down: true)
    page = call_service(service:)

    assert_locked_down_page_data(page)
    assert_locked_down_page_calls(match_repository,
                                  user_repository,
                                  predictions_repository,
                                  lockdown_policy)
  end

  def test_builds_origin_data_for_origin_match
    fixture = match_fixture(stage: 'Semi-finals')
    match_repository, _, _, _, service = build_service(match: fixture)
    page = call_service(service:)

    assert_equal({ ht_home_team: 'England' }, page.origin)
    assert_equal [
      [:load_match, 4, 6],
      [:load_origin, 6]
    ], match_repository.calls
  end

  def test_round_of_32_does_not_load_origin_data
    fixture = match_fixture(stage: 'Round of 32')
    match_repository, _, _, _, service = build_service(match: fixture)
    page = call_service(service:)

    assert_nil page.origin
    assert_equal [
      [:load_match, 4, 6]
    ], match_repository.calls
  end

  def test_builds_broadcaster_data_for_admin
    match_repository, _, _, _, service = build_service(match: default_fixture)
    page = call_service(service:, admin: true)

    assert_equal [{ id: '1', name: 'BBC' }], page.broadcasters
    assert_equal [
      [:load_match, 4, 6],
      [:load_broadcasters]
    ], match_repository.calls
  end

  private

  def assert_empty_optional_page_data(page)
    assert_nil page.users
    assert_nil page.predictions
    assert_nil page.origin
    assert_nil page.broadcasters
  end

  def assert_locked_down_page_data(page)
    assert page.match[:locked_down]
    assert page.result
    assert_equal [{ user_name: 'Alice' }], page.users
    assert_equal [{ user: 'Alice', home_prediction: 2 }], page.predictions
    assert_nil page.origin
    assert_nil page.broadcasters
  end

  def assert_locked_down_page_calls(match_repository,
                                    user_repository,
                                    predictions_repository,
                                    lockdown_policy)
    assert_equal [
      [:load_match, 4, 6]
    ], match_repository.calls
    assert_equal [
      [:load_users]
    ], user_repository.calls
    assert_equal [
      [:load_predictions, 6]
    ], predictions_repository.calls
    assert_equal [
      [:locked_down, 6]
    ], lockdown_policy.calls
  end

  def build_service(match:, locked_down: false)
    match_repository = FakeMatchRepository.new(match:)
    user_repository = FakeUserRepository.new()
    prediction_repository = FakePredictionsRepository.new()
    lockdown_policy = FakeLockdownPolicy.new(locked_down:)
    service = Services::Pages::Match.new(
      match_repository:,
      prediction_repository:,
      user_repository:,
      lockdown_policy:
    )
    return match_repository,
      user_repository,
      prediction_repository,
      lockdown_policy,
      service
  end

  def call_service(service:, admin: false)
    service.call(
      match_id: 6,
      user_id: 4,
      admin:
    )
  end

  def default_fixture
    {
      match_id: 6,
      home_score: nil,
      stage: 'Group Stages'
    }
  end

  def match_fixture(overrides)
    default_fixture.merge(overrides)
  end

  class FakeMatchRepository
    attr_reader :calls

    def initialize(match:)
      @match = match
      @calls = []
    end

    def load_match_with_user(user_id, match_id)
      calls << [:load_match, user_id, match_id]
      @match
    end

    def origin(match_id)
      calls << [:load_origin, match_id]
      { ht_home_team: 'England' }
    end

    def broadcasters
      calls << [:load_broadcasters]
      [{ id: '1', name: 'BBC' }]
    end
  end

  class FakeUserRepository
    attr_reader :calls

    def initialize
      @calls = []
    end

    def load_all_users_details
      calls << [:load_users]
      [{ user_name: 'Alice' }]
    end
  end

  class FakePredictionsRepository
    attr_reader :calls

    def initialize
      @calls = []
    end

    def get_predictions_results(match_id)
      calls << [:load_predictions, match_id]
      [{ user: 'Alice', home_prediction: 2 }]
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
