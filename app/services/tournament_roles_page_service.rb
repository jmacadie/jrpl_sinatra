class TournamentRolesPageService
  Result = Struct.new(:roles, keyword_init: true)

  def initialize(tournament_role_repository:)
    @tournament_role_repository = tournament_role_repository
  end

  def call
    Result.new(roles: @tournament_role_repository.load_roles)
  end
end
