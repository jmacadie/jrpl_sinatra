require_relative '../helpers/test_helpers'

class AdminPageServiceTest < Minitest::Test
  def test_loads_users_and_tournament_roles
    user_repository = FakeUserRepository.new
    tournament_role_repository = FakeTournamentRoleRepository.new
    service = AdminPageService.new(
      user_repository:,
      tournament_role_repository:
    )

    page = service.call

    assert_equal [{ user_id: 11, user_name: 'Clare Mac' }], page.users
    assert_equal [{ stage: 'Round of 16' }], page.roles
    assert_equal [[:load_all_users_details]], user_repository.calls
    assert_equal [[:load_roles]], tournament_role_repository.calls
  end

  class FakeUserRepository
    attr_reader :calls

    def initialize
      @calls = []
    end

    def load_all_users_details
      calls << [:load_all_users_details]
      [{ user_id: 11, user_name: 'Clare Mac' }]
    end
  end

  class FakeTournamentRoleRepository
    attr_reader :calls

    def initialize
      @calls = []
    end

    def load_roles
      calls << [:load_roles]
      [{ stage: 'Round of 16' }]
    end
  end
end
