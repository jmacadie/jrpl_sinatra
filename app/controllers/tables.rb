require_relative '../db/points'

class App < Sinatra::Application
  include DBPoints

  get '/tables' do
    scoring_system = 'Official'
    @tables = load_scoreboard_data(scoring_system)
    erb :tables
  end
end
