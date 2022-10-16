class App < Sinatra::Application
  get '/match/:match_id' do
    require_signed_in_user
    match_id = params[:match_id].to_i
    session[:criteria] ||= set_criteria_to_all_matches()
    load_match_details(match_id)
    @match[:locked_down] = match_locked_down?(@match)
    @predictions = @storage.get_match_predictions(match_id, 1)
    erb :match
  end

  # rubocop:todo Metrics/BlockLength
  post '/match/add_prediction' do
    require_signed_in_user
    match_id = params[:match_id].to_i
    move_next = to_bool(params[:next])
    home_prediction = params[:home_team_prediction].to_f
    away_prediction = params[:away_team_prediction].to_f
    load_match_details(match_id)
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
      match_id = @next_match[:match_id] if move_next
      redirect redirect_url(match_id, move_next: move_next)
    end
  end
  # rubocop:enable Metrics/BlockLength

  post '/match/add_result' do
    require_signed_in_as_admin
    home_score = params[:home_score].to_f
    away_score = params[:away_score].to_f
    match_id = params[:match_id].to_i
    load_match_details(match_id)
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
      redirect redirect_url(match_id)
    end
  end

  private

  def redirect_url(match_id, move_next: false)
    root = "/match/#{match_id}"
    return root if @ring.nil?
    return "#{root}?ring=#{@ring}" unless move_next
    "#{root}?ring=#{@next_match[:ring]}"
  end

  def load_match_details(match_id)
    @match = @storage.load_single_match(session[:user_id], match_id)
    return unless !params[:ring].nil?
    @ring = Ring.new({ ring: params[:ring] })
    @prev_match = @ring.prev_match
    @next_match = @ring.next_match
  end

  def to_bool(str)
    str == 'true'
  end
end
