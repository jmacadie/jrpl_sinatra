require "test_helpers"

class EditUserServiceTest < Minitest::Test
  def test_updates_username_password_and_email
    repository, service = build_service

    result = call_service(
      service,
      user_name: '  joe ',
      email: ' New@Email.com ',
      password: ' new-password ',
      password_confirmation: ' new-password '
    )

    assert_success(
      result,
      'The following have been updated: username, password, email.',
      user_name: 'joe',
      email: 'new@email.com'
    )
    assert_equal update_all_calls, repository.calls
  end

  def test_rejects_invalid_fields_and_current_password
    repository, service = build_service(
      username_exists: true,
      email_exists: true
    )

    result = call_service(
      service,
      current_password: 'wrong',
      user_name: 'Maccas',
      email: 'maccas@example.com',
      password: 'one',
      password_confirmation: 'two'
    )

    assert_failure(
      result,
      'That username already exists. Please choose a different username. ' \
      'The passwords do not match. ' \
      'That email address already exists. ' \
      'That is not the correct current password. Try again!'
    )
    assert_equal expected_validation_calls, repository.calls
  end

  def test_rejects_blank_username_and_email
    _, service = build_service

    result = call_service(service, user_name: ' ', email: ' ')

    assert_failure(
      result,
      'Username cannot be blank! Please enter a username. ' \
      'Email cannot be blank! Please enter an email.'
    )
  end

  def test_rejects_invalid_email
    _, service = build_service

    result = call_service(service, email: 'invalid')

    assert_failure(result, 'That is not a valid email address.')
  end

  def test_rejects_when_nothing_changed
    repository, service = build_service

    result = call_service(service)

    assert_failure(result, 'You have not changed any of your details.')
    assert_equal [[:load_user_credentials, 11]], repository.calls
  end

  def test_treats_current_password_as_unchanged_new_password
    _, service = build_service

    result = call_service(
      service,
      password: 'a',
      password_confirmation: 'a'
    )

    assert_failure(result, 'You have not changed any of your details.')
  end

  private

  def update_all_calls
    [
      [:load_user_credentials, 11],
      [:username_exists?, 'joe', 11],
      [:email_exists?, 'new@email.com', 11],
      [:change_username, 11, 'joe'],
      [:change_password, 11, 'new-password'],
      [:change_email, 11, 'new@email.com']
    ]
  end

  def build_service(username_exists: false, email_exists: false)
    repository = FakeUserRepository.new(
      username_exists:,
      email_exists:
    )
    service = Services::Accounts::EditUser.new(user_repository: repository)
    return repository, service
  end

  def call_service(service, overrides = {})
    details = {
      user_name: 'Clare Mac',
      email: 'clare@macadie.co.uk',
      password: '',
      password_confirmation: ''
    }.merge(overrides.except(:current_password))
    service.call(
      user_id: 11,
      current_password: 'a',
      details:,
      **overrides.slice(:current_password)
    )
  end

  def expected_validation_calls
    [
      [:load_user_credentials, 11],
      [:username_exists?, 'Maccas', 11],
      [:email_exists?, 'maccas@example.com', 11]
    ]
  end

  def assert_success(result, message, user_name:, email:)
    assert_predicate result, :success?
    assert_equal message, result.message
    assert_equal user_name, result.user_name
    assert_equal email, result.email
  end

  def assert_failure(result, message)
    refute_predicate result, :success?
    assert_equal message, result.message
    assert_nil result.user_name
    assert_nil result.email
  end

  class FakeUserRepository
    attr_reader :calls

    def initialize(username_exists: false, email_exists: false)
      @username_exists = username_exists
      @email_exists = email_exists
      @calls = []
    end

    def load_user_credentials(user_id)
      calls << [:load_user_credentials, user_id]
      {
        user_name: 'Clare Mac',
        email: 'clare@macadie.co.uk',
        pword: BCrypt::Password.create('a').to_s
      }
    end

    def username_exists?(user_name, except_user_id:)
      calls << [:username_exists?, user_name, except_user_id]
      @username_exists
    end

    def email_exists?(email, except_user_id:)
      calls << [:email_exists?, email, except_user_id]
      @email_exists
    end

    def change_username(user_id, user_name)
      calls << [:change_username, user_id, user_name]
    end

    def change_password(user_id, password)
      calls << [:change_password, user_id, password]
    end

    def change_email(user_id, email)
      calls << [:change_email, user_id, email]
    end
  end
end
