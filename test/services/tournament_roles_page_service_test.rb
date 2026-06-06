require_relative '../helpers/test_helpers'

class TournamentRolesPageServiceTest < Minitest::Test
  def test_loads_tournament_roles
    repository = FakeTournamentRoleRepository.new
    service = TournamentRolesPageService.new(
      tournament_role_repository: repository
    )

    page = service.call

    assert_equal [{ stage: 'Round of 16' }], page.roles
    assert_equal [[:load_roles]], repository.calls
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
