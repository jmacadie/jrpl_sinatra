class App < Sinatra::Application
  get '/tables' do
    scoring_system = 'Official'
    @tables = @storage.load_scoreboard_data(scoring_system)
    erb :tables
  end
end
