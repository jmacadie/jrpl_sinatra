require_relative '../../helpers/test_helpers'

class RememberMeLoginServiceTest < Minitest::Test
  def test_logs_in_with_valid_series_and_token
    repository, service = build_service

    result = service.call(series_id: 'series', token: 'valid-token')

    assert_predicate result, :success?
    assert_equal 4, result.user_id
    assert_equal 'series', result.series_id
    assert_equal [
      [:user_from_series, 'series'],
      [:update_token, 'series', 'rotated-token']
    ], repository.calls
  end

  def test_rotates_token_after_successful_login
    _, service = build_service

    result = service.call(series_id: 'series', token: 'valid-token')

    assert_equal 'rotated-token', result.new_token
    refute_equal 'valid-token', result.new_token
  end

  def test_rejects_invalid_token_and_deletes_stored_cookie
    repository, service = build_service

    result = service.call(series_id: 'series', token: 'invalid-token')

    refute_predicate result, :success?
    assert_predicate result, :invalid_token?
    assert_equal 'series', result.series_id
    assert_equal [
      [:user_from_series, 'series'],
      [:delete_cookie_data, 'series']
    ], repository.calls
  end

  def test_rejects_unknown_series_without_deleting_cookie_data
    repository, service = build_service(user: nil)

    result = service.call(series_id: 'unknown', token: 'valid-token')

    refute_predicate result, :success?
    refute_predicate result, :invalid_token?
    assert_equal [[:user_from_series, 'unknown']], repository.calls
  end

  def test_ignores_missing_series
    repository, service = build_service

    result = service.call(series_id: nil, token: 'valid-token')

    refute_predicate result, :success?
    assert_empty repository.calls
  end

  def test_ignores_missing_token
    repository, service = build_service

    result = service.call(series_id: 'series', token: nil)

    refute_predicate result, :success?
    assert_empty repository.calls
  end

  private

  def build_service(user: default_user)
    repository = FakeCookieRepository.new(user:)
    service = Services::RememberMeLogin.new(
      cookie_repository: repository,
      token_generator: -> { 'rotated-token' }
    )
    return repository, service
  end

  def default_user
    {
      user_id: 4,
      token: BCrypt::Password.create('valid-token').to_s
    }
  end

  class FakeCookieRepository
    attr_reader :calls

    def initialize(user:)
      @user = user
      @calls = []
    end

    def user_from_series(series_id)
      calls << [:user_from_series, series_id]
      @user
    end

    def update_token(series_id, token)
      calls << [:update_token, series_id, token]
    end

    def delete_cookie_data(series_id)
      calls << [:delete_cookie_data, series_id]
    end
  end
end
