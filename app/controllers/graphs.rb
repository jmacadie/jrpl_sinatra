class App < Sinatra::Application
  get '/graphs' do
    require_signed_in_user
    @users = settings.graphs_page_service.page.users
    erb :graphs
  end

  get '/graphs/data' do
    require_signed_in_user
    content_type :json
    { points: settings.graphs_page_service.points }.to_json
  end
end
