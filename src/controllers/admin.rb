class App < Sinatra::Application
  get '/admin' do
    require_signed_in_as_admin
    @users = @storage.load_all_users_details
    @roles = @storage.tournament_roles
    @show = params[:show]
    erb :admin
  end
end
