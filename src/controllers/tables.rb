#class App < Sinatra::Base
  get '/scoreboard' do
    @scoring_system = 'official'
    @scores = @storage.load_scoreboard_data(@scoring_system)
    erb :scoreboard
  end

  get '/toggle_scoring_system' do
    @scoring_system = params[:scoring_system]
    @scores = @storage.load_scoreboard_data(@scoring_system)
    erb :scoreboard
  end
#end
