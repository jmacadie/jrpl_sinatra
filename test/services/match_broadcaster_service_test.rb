require_relative '../helpers/test_helpers'

class MatchBroadcasterServiceTest < Minitest::Test
  def test_changes_match_broadcaster
    match_repository = FakeMatchRepository.new
    result = MatchBroadcasterService.new(match_repository:).call(
      match_id: 6,
      broadcaster_id: 2
    )

    assert_predicate result, :success?
    assert_equal 'Broadcaster changed', result.message
    assert_equal 'success', result.status
    assert_equal 6, result.match_id
    assert_equal 2, result.broadcaster_id
    assert_equal [
      [:change_broadcaster, 6, 2]
    ], match_repository.calls
  end

  class FakeMatchRepository
    attr_reader :calls

    def initialize
      @calls = []
    end

    def change_broadcaster(match_id, broadcaster_id)
      calls << [:change_broadcaster, match_id, broadcaster_id]
    end
  end
end
