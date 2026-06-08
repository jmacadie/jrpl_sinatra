require_relative '../../helpers/test_helpers'

class DeleteUserServiceTest < Minitest::Test
  def test_deletes_existing_user
    repository, service = build_service(user_name: 'DTM')

    result = service.call(user_id: '6', current_user_id: 4)

    assert_equal 'DTM is no longer with us 🕳️', result.message
    assert_equal 'warn', result.message_level
    assert_equal [
      [:user_name, 6],
      [:delete_user, 6]
    ], repository.calls
  end

  def test_rejects_self_delete
    repository, service = build_service(user_name: 'Maccas')

    result = service.call(user_id: '4', current_user_id: 4)

    assert_equal "You can't delete yourself, you lemon 🍋", result.message
    assert_equal 'danger', result.message_level
    assert_empty repository.calls
  end

  def test_rejects_unknown_user
    repository, service = build_service(user_name: nil)

    result = service.call(user_id: '100', current_user_id: 4)

    assert_equal '100 is not a valid user_id', result.message
    assert_equal 'danger', result.message_level
    assert_equal [[:user_name, 100]], repository.calls
  end

  def test_preserves_invalid_submitted_id_in_message
    repository, service = build_service(user_name: nil)

    result = service.call(user_id: 'a', current_user_id: 4)

    assert_equal 'a is not a valid user_id', result.message
    assert_equal [[:user_name, 0]], repository.calls
  end

  private

  def build_service(user_name:)
    repository = FakeUserRepository.new(user_name:)
    service = Services::DeleteUser.new(user_repository: repository)
    return repository, service
  end

  class FakeUserRepository
    attr_reader :calls

    def initialize(user_name:)
      @user_name = user_name
      @calls = []
    end

    def user_name(user_id)
      calls << [:user_name, user_id]
      @user_name
    end

    def delete_user(user_id)
      calls << [:delete_user, user_id]
    end
  end
end
