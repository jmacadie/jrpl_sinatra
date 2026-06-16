module Services
  module Pages
    class Admin
      Page = Struct.new(:users, :roles, keyword_init: true)

      def initialize(user_repository:, tournament_role_repository:)
        @user_repository = user_repository
        @tournament_role_repository = tournament_role_repository
      end

      def call
        rows = @tournament_role_repository.load_role_rows
        Page.new(
          users: @user_repository.load_all_users_details,
          roles: Presenters::TournamentRoles.new(rows:).call
        )
      end
    end
  end
end
