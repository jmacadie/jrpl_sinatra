require "test_helpers"

class SignInServiceTest < Minitest::Test
  def test_returns_session_data_for_valid_credentials
    repository = FakeUserRepository.new(user: user_fixture)
    service = Services::Accounts::SignIn.new(user_repository: repository)

    result = service.call(login: '  Maccas ', password: ' a ')

    assert_predicate result, :success?
    assert_equal 4, result.user_id
    assert_equal 'Maccas', result.user_name
    assert_equal 'maccas@example.com', result.email
    assert_equal 'Admin', result.roles
    assert_equal [[:find_sign_in_user, 'Maccas']], repository.calls
  end

  def test_rejects_invalid_password
    repository = FakeUserRepository.new(user: user_fixture)
    service = Services::Accounts::SignIn.new(user_repository: repository)

    result = service.call(login: 'Maccas', password: 'wrong')

    refute_predicate result, :success?
    assert_nil result.user_id
  end

  def test_rejects_unknown_login
    repository = FakeUserRepository.new(user: nil)
    service = Services::Accounts::SignIn.new(user_repository: repository)

    result = service.call(login: 'unknown', password: 'a')

    refute_predicate result, :success?
    assert_equal [[:find_sign_in_user, 'unknown']], repository.calls
  end

  private

  def user_fixture
    {
      user_id: 4,
      user_name: 'Maccas',
      email: 'Maccas@Example.com',
      pword: BCrypt::Password.create('a').to_s,
      roles: 'Admin'
    }
  end

  class FakeUserRepository
    attr_reader :calls

    def initialize(user:)
      @user = user
      @calls = []
    end

    def find_sign_in_user(login)
      calls << [:find_sign_in_user, login]
      @user
    end
  end
end
