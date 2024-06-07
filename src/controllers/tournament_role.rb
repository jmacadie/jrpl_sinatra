class App < Sinatra::Application
  post '/tournament_role' do
    require_signed_in_as_admin
    role = params[:role].to_i
    team = params[:team].to_i
    validate_tournament_role(role, team)
    if team == 0
      @storage.reset_tournament_role(role)
    else
      @storage.set_tournament_role(role, team)
    end
    redirect "/admin?show=#{role}"
  end

  private

  def validate_tournament_role(role, team)
    # Check role in valid range
    # TODO: this is bad it's a hard-coded range that references data in the
    # database
    # Fortunately this data is global to a whole tournament and shouldn't
    # change which is why I've chanced my arm here rather than validating
    # with another DB call
    session[:message] = "Invalid role number: #{role}" if !(role in 25..54)

    # Check team in valid range
    session[:message] = "Invalid team number: #{team}" if !(team in 0..24)

    # If we have no message, we must be ok
    return unless session[:message]

    # Otherwise do bad stuff
    session[:message_level] = 'danger'
    status 422
    redirect '/admin'
  end
end
