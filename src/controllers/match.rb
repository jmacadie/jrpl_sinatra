class App < Sinatra::Application
  get '/match/:match_id' do
    require_signed_in_user
    match_id = params[:match_id].to_i
    if session[:criteria].nil?
      session[:criteria] = set_criteria_to_all_matches()
    end
    @match = @storage.load_single_match(session[:user_id], match_id)
    @match[:locked_down] = match_locked_down?(@match)
    # session[:message] = 'Match locked down!' if @match[:locked_down]
    erb :match_details
  end
  
  post '/match/add_prediction' do
    require_signed_in_user
    match_id = params[:match_id].to_i
    @match = @storage.load_single_match(session[:user_id], match_id)
    home_prediction = params[:home_team_prediction].to_f
    away_prediction = params[:away_team_prediction].to_f
    session[:message] = prediction_error(@match, home_prediction, away_prediction)
    if session[:message]
      status 422
      erb :match_details
    else
      @storage.add_prediction(
        session[:user_id],
        match_id,
        home_prediction.to_i,
        away_prediction.to_i
      )
      session[:message] = 'Prediction submitted.'
      redirect "/match/#{match_id}"
    end
  end
  
  post '/match/add_result' do
    require_signed_in_as_admin
    home_points = params[:home_pts].to_f
    away_points = params[:away_pts].to_f
    match_id = params[:match_id].to_i
    @match = @storage.load_single_match(session[:user_id], match_id)
    session[:message] = match_result_error(@match, home_points, away_points)
    if session[:message]
      status 422
      erb :match_details
    else
      @storage.add_result(
        match_id, home_points.to_i, away_points.to_i, session[:user_id]
      )
      update_scoreboard(match_id)
      session[:message] = 'Result submitted.'
      redirect "/match/#{match_id}"
    end
  end
end
