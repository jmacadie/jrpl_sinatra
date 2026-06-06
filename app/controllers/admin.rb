require_relative '../repositories/users'

class App < Sinatra::Application
  include DBUsers

  get '/admin' do
    require_signed_in_as_admin
    @users = load_all_users_details
    @roles = settings.tournament_roles_page_service.call.roles
    erb :admin
  end
end
