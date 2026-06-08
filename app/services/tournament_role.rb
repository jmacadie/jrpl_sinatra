module Services
  class TournamentRole
    Result = Struct.new(
      :success,
      :message,
      :status,
      :reset,
      keyword_init: true
    ) do
      def success?
        success
      end
    end

    def initialize(tournament_role_repository:)
      @tournament_role_repository = tournament_role_repository
    end

    def call(role_id:, team_id:)
      message = validation_message(role_id, team_id)
      return failure(message) if message

      update_role(role_id, team_id)
    rescue PG::UniqueViolation
      failure(team_already_selected_message(team_id))
    end

    private

    def validation_message(role_id, team_id)
      maximum_team_id, maximum_role_id =
        @tournament_role_repository.role_numbers

      return "Invalid team number: #{team_id}" if
        team_id.negative? || team_id > maximum_team_id
      return "Invalid role number: #{role_id}" if
        role_id <= maximum_team_id || role_id > maximum_role_id
      team_already_selected_message(team_id) if
        team_id.positive? &&
        @tournament_role_repository.team_selected_in_stage?(role_id, team_id)
    end

    def update_role(role_id, team_id)
      role_name = @tournament_role_repository.role_name(role_id)
      return reset_role(role_id, role_name) if team_id.zero?

      @tournament_role_repository.set_team(role_id, team_id)
      team_name = @tournament_role_repository.team_name(team_id)
      success("#{role_name} set to #{team_name}", reset: false)
    end

    def reset_role(role_id, role_name)
      @tournament_role_repository.reset_team(role_id)
      success("#{role_name} reset", reset: true)
    end

    def team_already_selected_message(team_id)
      team_name = @tournament_role_repository.team_name(team_id)
      "#{team_name} is already selected for this stage"
    end

    def success(message, reset:)
      Result.new(
        success: true,
        message:,
        status: 'success',
        reset:
      )
    end

    def failure(message)
      Result.new(
        success: false,
        message:,
        status: 'danger'
      )
    end
  end
end
