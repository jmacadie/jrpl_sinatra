require "test_helpers"

class SignUpServiceTest < Minitest::Test
  def test_creates_user_and_returns_session_data
    repository = FakeUserRepository.new
    hasher = FakeHasher.new
    service = Services::Accounts::SignUp.new(user_repository: repository,
                                             hasher:)

    result = call_service(
      service,
      user_name: ' joe ',
      email: ' Joe@Example.com ',
      password: ' secret ',
      password_confirmation: ' secret ',
      bot_check: ' JrPl '
    )

    assert_success(result, repository, hasher)
  end

  def test_rejects_duplicate_username_and_email
    repository = FakeUserRepository.new(
      username_taken: true,
      email_taken: true
    )
    hasher = FakeHasher.new
    service = Services::Accounts::SignUp.new(user_repository: repository,
                                             hasher:)

    result = call_service(service)

    assert_failure(
      result,
      'That username already exists. Please choose a different username. ' \
      'That email address already exists.'
    )
    assert_equal validation_calls, repository.calls
  end

  def test_rejects_blank_username_password_and_email
    repository = FakeUserRepository.new
    hasher = FakeHasher.new
    service = Services::Accounts::SignUp.new(user_repository: repository,
                                             hasher:)

    result = call_service(
      service,
      user_name: '',
      email: '',
      password: '',
      password_confirmation: ''
    )

    assert_failure(
      result,
      'Username cannot be blank! Please enter a username. ' \
      'Password cannot be blank! Please enter a password. ' \
      'Email cannot be blank! Please enter an email.'
    )
  end

  def test_rejects_mismatched_password_and_invalid_email
    repository = FakeUserRepository.new
    hasher = FakeHasher.new
    service = Services::Accounts::SignUp.new(user_repository: repository,
                                             hasher:)

    result = call_service(
      service,
      email: 'invalid',
      password_confirmation: 'different'
    )

    assert_failure(
      result,
      'The passwords do not match. That is not a valid email address.'
    )
  end

  def test_rejects_missing_bot_check
    repository = FakeUserRepository.new
    hasher = FakeHasher.new
    service = Services::Accounts::SignUp.new(user_repository: repository,
                                             hasher:)

    result = call_service(service, bot_check: nil)

    assert_failure(result, Services::Accounts::SignUp::BOT_CHECK_MESSAGE)
  end

  private

  def assert_success(result, repository, hasher)
    assert_predicate result, :success?
    assert_equal 'Your account has been created.', result.message
    assert_equal 35, result.user_id
    assert_equal 'joe', result.user_name
    assert_equal 'joe@example.com', result.email
    assert_nil result.roles
    assert_equal successful_calls, repository.calls
    assert_equal [[:hash, 'secret']], hasher.calls
  end

  def successful_calls
    [
      [:username_taken?, 'joe'],
      [:email_taken?, 'joe@example.com'],
      [:create_user, 'joe', 'joe@example.com', 'scrambled']
    ]
  end

  def call_service(service, overrides = {})
    details = {
      user_name: 'joanna',
      email: 'joanna@example.com',
      password: 'secret',
      password_confirmation: 'secret',
      bot_check: 'JRPL'
    }.merge(overrides)
    service.call(details:)
  end

  def validation_calls
    [
      [:username_taken?, 'joanna'],
      [:email_taken?, 'joanna@example.com']
    ]
  end

  def assert_failure(result, message)
    refute_predicate result, :success?
    assert_equal message, result.message
    assert_nil result.user_id
  end

  class FakeUserRepository
    attr_reader :calls

    def initialize(username_taken: false, email_taken: false)
      @username_taken = username_taken
      @email_taken = email_taken
      @calls = []
    end

    def username_taken?(user_name:)
      calls << [:username_taken?, user_name]
      @username_taken
    end

    def email_taken?(email:)
      calls << [:email_taken?, email]
      @email_taken
    end

    def create_user(user_name:, email:, password_digest:)
      calls << [:create_user, user_name, email, password_digest]
      {
        user_id: 35,
        user_name:,
        email:,
        roles: nil
      }
    end
  end

  class FakeHasher
    attr_reader :calls

    def initialize
      @calls = []
    end

    def hash(password:)
      calls << [:hash, password]
      'scrambled'
    end
  end
end
