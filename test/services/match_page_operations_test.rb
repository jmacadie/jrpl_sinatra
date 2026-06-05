require_relative '../helpers/test_helpers'

class MatchPageOperationsTest < Minitest::Test
  def test_delegates_match_page_operations_to_explicit_collaborators
    operations, match_repository, match_prediction_repository, user_repository =
      build_operations

    assert_equal({ match_id: 6 }, operations.load_match(4, 6))
    assert_equal [{ user_name: 'Alice' }], operations.load_users
    assert_equal [{ user: 'Alice' }], operations.load_predictions(6)
    assert_equal({ ht_home_team: 'England' }, operations.load_origin(6))
    assert_equal [{ id: '1', name: 'BBC' }], operations.load_broadcasters

    assert_equal [
      [:load_single_match, 4, 6],
      [:match_origin, 6],
      [:broadcasters]
    ], match_repository.calls
    assert_equal [
      [:get_match_predictions, 6, 1]
    ], match_prediction_repository.calls
    assert_equal [
      [:load_all_users_details]
    ], user_repository.calls
  end

  def build_operations
    match_repository = FakeMatchRepository.new
    match_prediction_repository = FakeMatchPredictionRepository.new
    user_repository = FakeUserRepository.new
    [
      MatchPageOperations.new(
        match_repository:,
        match_prediction_repository:,
        user_repository:
      ),
      match_repository,
      match_prediction_repository,
      user_repository
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

    def match_origin(match_id)
      calls << [:match_origin, match_id]
      { ht_home_team: 'England' }
    end

    def broadcasters
      calls << [:broadcasters]
      [{ id: '1', name: 'BBC' }]
    end
  end

  class FakeMatchPredictionRepository
    attr_reader :calls

    def initialize
      @calls = []
    end

    def get_match_predictions(match_id, scoring_system)
      calls << [:get_match_predictions, match_id, scoring_system]
      [{ user: 'Alice' }]
    end
  end

  class FakeUserRepository
    attr_reader :calls

    def initialize
      @calls = []
    end

    def load_all_users_details
      calls << [:load_all_users_details]
      [{ user_name: 'Alice' }]
    end
  end
end
