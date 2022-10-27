class App < Sinatra::Application
  get '/match/:match_id' do
    require_signed_in_user
    match_id = params[:match_id].to_i
    load_match_details(match_id)
    @match[:locked_down] = match_locked_down?(@match)
    @predictions = @storage.get_match_predictions(match_id, 1)
    erb :match
  end

  post '/match/add_prediction' do
    require_signed_in_user
    match_id = params[:match_id].to_i
    home_prediction = params[:home_team_prediction].to_f
    away_prediction = params[:away_team_prediction].to_f
    move_next = to_bool(params[:next])
    load_match_details(match_id)
    return erb :match unless
      validate_prediction(home_prediction, away_prediction)
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

  post '/match/add_result' do
    require_signed_in_as_admin
    match_id = params[:match_id].to_i
    home_score = params[:home_score].to_f
    away_score = params[:away_score].to_f
    load_match_details(match_id)
    return erb :match unless
      validate_result(home_score, away_score)
    home_score = home_score.to_i
    away_score = away_score.to_i
    @storage.add_result(
      match_id, home_score, away_score, session[:user_id]
    )
    update_scoreboard(match_id, home_score, away_score)
    send_result_email(match_id)
    session[:message] = 'Result submitted'
    redirect redirect_url(match_id)
  end

  private

  def validate_prediction(home, away)
    session[:message] = prediction_error(@match, home, away)
    if session[:message]
      status 422
      return false
    end
    true
  end

  def validate_result(home, away)
    session[:message] = match_result_error(@match, home, away)
    if session[:message]
      status 422
      return false
    end
    true
  end

  def redirect_url(match_id, move_next: false)
    root = "/match/#{match_id}"
    return root if @ring.nil?
    return "#{root}?ring=#{@ring}" unless move_next
    "#{root}?ring=#{@next_match[:ring]}"
  end

  def load_match_details(match_id)
    @match = @storage.load_single_match(session[:user_id], match_id)
    return unless !params[:ring].nil? && params[:ring] != ""
    @ring = Ring.new({ ring: params[:ring] })
    @prev_match = @ring.prev_match
    @next_match = @ring.next_match
  end

  def to_bool(str)
    str == 'true'
  end

  def send_result_email(match_id)
    match = @storage.load_single_match(1, match_id)
    predictions = @storage.get_match_predictions(match_id)
    table = @storage.load_scoreboard_data('Official')
    subject = result_email_subject(match)
    body = result_email_body(match, predictions, table)
    send_email_all(
      subject: subject,
      body: body
    )
    @storage.record_results_email_sent(match_id)
  end

  def result_email_subject(match)
    "Results for #{home_name(match)} vs. #{away_name(match)}"
  end

  def result_email_body(match, predictions, table)
    erb :'email/result',
        layout: false,
        locals: { match: match, predictions: predictions, table: table }
  end
end
