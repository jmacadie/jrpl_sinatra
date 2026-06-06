class App < Sinatra::Application
  get '/graphs' do
    user_signed_in?
    @users = settings.graphs_page_service.page.users
    erb :graphs
  end

  get '/graphs/data' do
    user_signed_in?
    content_type :json
    { points: settings.graphs_page_service.points }.to_json
  end
end
