require_relative '../db/tournament_roles'
require_relative '../db/users'

class App < Sinatra::Application
  include DBUsers
  include DBTournamentRoles

  get '/admin' do
    require_signed_in_as_admin
    @users = load_all_users_details
    @roles = tournament_roles
    erb :admin
  end
end
