class App < Sinatra::Application
  get '/admin' do
    require_signed_in_as_admin
    page = settings.admin_page_service.call
    erb :admin,
        locals: {
          users: page.users,
          roles: page.roles
        }
  end
end
