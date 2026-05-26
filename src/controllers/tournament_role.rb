require_relative '../db/tournament_roles'

class App < Sinatra::Application
  include DBTournamentRoles

  post '/tournament_role' do
    require_signed_in_as_admin
    role = params[:role].to_i
    team = params[:team].to_i
    error = validate_tournament_role(role, team)
    if error
      content_type :json
      status 422
      return { status: 'danger', message: error }.to_json
    end

    message, reset = update_data(role, team)
    content_type :json
    { message: message,
      status: 'success',
      reset: reset }.to_json
  end

  private

  def validate_tournament_role(role, team)
    numbers = tournament_role_numbers()

    return "Invalid team number: #{team}" if team.negative? || team > numbers[0]
    return "Invalid role number: #{role}" if
      role <= numbers[0] || role > numbers[1]

    nil
  end

  def update_data(role, team)
    name = tournament_role_name(role)
    if team == 0
      reset_tournament_role(role)
      return "#{name} reset", true
    end

    set_tournament_role(role, team)
    team_name = team_name(team)
    return "#{name} set to #{team_name}", false
  end
end
