class App < Sinatra::Application
  get '/match/:match_id' do
    require_signed_in_user
    match_id = params[:match_id].to_i
    session[:criteria] ||= set_criteria_to_all_matches()
    @match = @storage.load_single_match(session[:user_id], match_id)
    if !params[:ring].nil?
      ring = Ring.new({ ring: params[:ring] })
      @prev_match = ring.prev_match
      @next_match = ring.next_match
    end
    @match[:locked_down] = match_locked_down?(@match)
    @predictions = @storage.get_match_predictions(match_id, 1)
    erb :match
  end

  post '/match/add_prediction' do
    require_signed_in_user
    match_id = params[:match_id].to_i
    @match = @storage.load_single_match(session[:user_id], match_id)
    home_prediction = params[:home_team_prediction].to_f
    away_prediction = params[:away_team_prediction].to_f
    session[:message] =
      prediction_error(@match, home_prediction, away_prediction)
    if session[:message]
      status 422
      erb :match
    else
      @storage.add_prediction(
        session[:user_id],
        match_id,
        home_prediction.to_i,
        away_prediction.to_i
      )
      session[:message] = 'Prediction submitted'
      redirect "/match/#{match_id}"
    end
  end

  post '/match/add_result' do
    require_signed_in_as_admin
    home_score = params[:home_score].to_f
    away_score = params[:away_score].to_f
    match_id = params[:match_id].to_i
    # TODO: This is an excessive data load
    @match = @storage.load_single_match(session[:user_id], match_id)
    session[:message] = match_result_error(@match, home_score, away_score)
    if session[:message]
      status 422
      erb :match
    else
      home_score = home_score.to_i
      away_score = away_score.to_i
      @storage.add_result(
        match_id, home_score, away_score, session[:user_id]
      )
      update_scoreboard(match_id, home_score, away_score)
      session[:message] = 'Result submitted'
      redirect "/match/#{match_id}"
    end
  end
end
