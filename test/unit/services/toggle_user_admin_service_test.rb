require_relative '../../helpers/test_helpers'

class ToggleUserAdminServiceTest < Minitest::Test
  def test_grants_admin_role_when_user_is_not_an_admin
    repository, service = build_service(admin: false)

    result = service.call(user_id: '11', action: 'grant_admin')

    assert result.changed
    assert_equal [
      [:admin?, 11],
      [:grant_admin, 11]
    ], repository.calls
  end

  def test_does_not_grant_admin_role_when_user_is_already_an_admin
    repository, service = build_service(admin: true)

    result = service.call(user_id: '11', action: 'grant_admin')

    refute result.changed
    assert_equal [[:admin?, 11]], repository.calls
  end

  def test_revokes_admin_role_when_user_is_an_admin
    repository, service = build_service(admin: true)

    result = service.call(user_id: '11', action: 'revoke_admin')

    assert result.changed
    assert_equal [
      [:admin?, 11],
      [:revoke_admin, 11]
    ], repository.calls
  end

  def test_does_not_revoke_admin_role_when_user_is_not_an_admin
    repository, service = build_service(admin: false)

    result = service.call(user_id: '11', action: 'revoke_admin')

    refute result.changed
    assert_equal [[:admin?, 11]], repository.calls
  end

  def test_ignores_unknown_action
    repository, service = build_service(admin: false)

    result = service.call(user_id: '11', action: 'unknown')

    refute result.changed
    assert_empty repository.calls
  end

  private

  def build_service(admin:)
    repository = FakeUserRepository.new(admin:)
    service = Services::ToggleUserAdmin.new(user_repository: repository)
    return repository, service
  end

  class FakeUserRepository
    attr_reader :calls

    def initialize(admin:)
      @admin = admin
      @calls = []
    end

    def admin?(user_id)
      calls << [:admin?, user_id]
      @admin
    end

    def grant_admin(user_id)
      calls << [:grant_admin, user_id]
    end

    def revoke_admin(user_id)
      calls << [:revoke_admin, user_id]
    end
  end
end
