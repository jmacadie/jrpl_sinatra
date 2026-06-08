require_relative '../helpers/test_helpers'

class CookieRepositoryTest < Minitest::Test
  def test_saves_hashed_cookie_token
    query_runner = FakeQueryRunner.new
    repository = Repositories::Cookie.new(query_runner:)

    repository.save_new_cookie(4, 'series', 'plain-token')

    _, user_id, series_id, token, timestamp = query_runner.calls.first
    assert_equal 4, user_id
    assert_equal 'series', series_id
    assert BCrypt::Password.new(token) == 'plain-token'
    assert_instance_of Time, timestamp
  end

  def test_loads_user_for_series
    result = FakeResult.new(
      [{ 'user_id' => '4', 'token' => 'hashed-token' }]
    )
    query_runner = FakeQueryRunner.new(results: [result])
    repository = Repositories::Cookie.new(query_runner:)

    assert_equal(
      { user_id: 4, token: 'hashed-token' },
      repository.user_from_series('series')
    )
  end

  def test_returns_nil_for_unknown_series
    query_runner = FakeQueryRunner.new(results: [FakeResult.new])
    repository = Repositories::Cookie.new(query_runner:)

    assert_nil repository.user_from_series('missing')
  end

  class FakeQueryRunner
    attr_reader :calls

    def initialize(results: [])
      @results = results
      @calls = []
    end

    def run_query(statement, *params)
      calls << [statement, *params]
      @results.shift || FakeResult.new
    end
  end

  class FakeResult < Array
    def ntuples
      size
    end
  end
end
