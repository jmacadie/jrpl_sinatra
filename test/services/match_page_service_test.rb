require_relative '../helpers/test_helpers'

class MatchPageServiceTest < Minitest::Test
  def test_builds_page_data_for_unlocked_match
    operations = FakeMatchPageOperations.new(
      match: match_fixture(match_datetime: unlocked_time)
    )

    page = call_service(operations:)

    assert_equal 6, page.match[:match_id]
    refute page.match[:locked_down]
    refute page.result
    assert_empty_optional_page_data(page)
    assert_equal [
      [:load_match, 4, 6]
    ], operations.calls
  end

  def test_builds_page_data_for_locked_down_match
    operations = FakeMatchPageOperations.new(
      match: match_fixture(
        match_datetime: locked_down_time,
        home_score: 2
      )
    )

    page = call_service(operations:)

    assert page.match[:locked_down]
    assert page.result
    assert_locked_down_page_data(page)
    assert_nil page.origin
    assert_nil page.broadcasters
    assert_equal [
      [:load_match, 4, 6],
      [:load_users],
      [:load_predictions, 6]
    ], operations.calls
  end

  def test_builds_origin_data_for_origin_match
    operations = FakeMatchPageOperations.new(
      match: match_fixture(
        match_datetime: unlocked_time,
        stage: 'Semi-finals'
      )
    )

    page = call_service(operations:)

    assert_equal({ ht_home_team: 'England' }, page.origin)
    assert_equal [
      [:load_match, 4, 6],
      [:load_origin, 6]
    ], operations.calls
  end

  def test_round_of_32_does_not_load_origin_data
    operations = FakeMatchPageOperations.new(
      match: match_fixture(
        match_datetime: unlocked_time,
        stage: 'Round of 32'
      )
    )

    page = call_service(operations:)

    assert_nil page.origin
    assert_equal [
      [:load_match, 4, 6]
    ], operations.calls
  end

  def test_builds_broadcaster_data_for_admin
    operations = FakeMatchPageOperations.new(
      match: match_fixture(match_datetime: unlocked_time)
    )

    page = call_service(operations:, admin: true)

    assert_equal [{ id: '1', name: 'BBC' }], page.broadcasters
    assert_equal [
      [:load_match, 4, 6],
      [:load_broadcasters]
    ], operations.calls
  end

  private

  def assert_empty_optional_page_data(page)
    assert_nil page.users
    assert_nil page.predictions
    assert_nil page.origin
    assert_nil page.broadcasters
  end

  def assert_locked_down_page_data(page)
    assert_equal [{ user_name: 'Alice' }], page.users
    assert_equal [{ user: 'Alice', home_prediction: 2 }], page.predictions
  end

  def build_service(operations:)
    MatchPageService.new(operations:)
  end

  def call_service(operations:, admin: false)
    build_service(operations:).call(
      match_id: 6,
      user_id: 4,
      admin:
    )
  end

  def match_fixture(overrides)
    {
      match_id: 6,
      match_datetime: unlocked_time,
      home_score: nil,
      stage: 'Group Stages'
    }.merge(overrides)
  end

  def locked_down_time
    Time.now - 60
  end

  def unlocked_time
    Time.now + App::LOCKDOWN_BUFFER + 60
  end

  class FakeMatchPageOperations
    attr_reader :calls

    def initialize(match:)
      @match = match
      @calls = []
    end

    def load_match(user_id, match_id)
      calls << [:load_match, user_id, match_id]
      @match
    end

    def load_users
      calls << [:load_users]
      [{ user_name: 'Alice' }]
    end

    def load_predictions(match_id)
      calls << [:load_predictions, match_id]
      [{ user: 'Alice', home_prediction: 2 }]
    end

    def load_origin(match_id)
      calls << [:load_origin, match_id]
      { ht_home_team: 'England' }
    end

    def load_broadcasters
      calls << [:load_broadcasters]
      [{ id: '1', name: 'BBC' }]
    end
  end
end
