require "test_helpers"

class AdminPageServiceTest < Minitest::Test
  def test_loads_users_and_tournament_roles
    user_repository = FakeUserRepository.new
    tournament_role_repository = FakeTournamentRoleRepository.new
    service = Services::Pages::Admin.new(
      user_repository:,
      tournament_role_repository:
    )

    page = service.call

    assert_equal [{ user_id: 11, user_name: 'Clare Mac' }], page.users
    assert_equal expected_roles, page.roles
    assert_equal [[:load_all_users_details]], user_repository.calls
    assert_equal [[:load_role_rows]], tournament_role_repository.calls
  end

  private

  def expected_roles
    [
      {
        stage: 'Round of 16',
        group_roles: [
          {
            role: 'Winner Group A',
            id: '25',
            selected: 0,
            teams: [
              {
                team_id: 4,
                team_name: 'Switzerland',
                disabled: false
              }
            ]
          }
        ]
      }
    ]
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

    def load_role_rows
      calls << [:load_role_rows]
      [
        {
          stage: 'Round of 16',
          role: 'Winner Group A',
          id: '25',
          selected_team_id: nil,
          team_id: '4',
          team: 'Switzerland'
        }
      ]
    end
  end
end
