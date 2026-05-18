require_relative '../db/tournament_roles'

class App < Sinatra::Application
  include DBTournamentRoles

  post '/tournament_role' do
    require_signed_in_as_admin
    role = params[:role].to_i
    team = params[:team].to_i
    validate_tournament_role(role, team)
    if team == 0
      reset_tournament_role(role)
    else
      set_tournament_role(role, team)
    end
    redirect "/admin?show=#{role}"
  end

  private

  def validate_tournament_role(role, team)
    numbers = tournament_role_numbers()

    if team < 0 || team > numbers[0]
      session[:message] =
        "Invalid team number: #{team}"
    end

    if role <= numbers[0] || role > numbers[1]
      session[:message] =
        "Invalid role number: #{role}"
    end

    # If we have no message, we must be ok
    return unless session[:message]

    # Otherwise do bad stuff
    session[:message_level] = 'danger'
    status 422
    redirect '/admin'
  end
end
