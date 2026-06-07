class App < Sinatra::Application
  get '/tables' do
    @tables = settings.tables_page_service.call.tables
    erb :tables
  end
end
