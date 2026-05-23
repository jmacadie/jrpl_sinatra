require_relative '../db/emails'
require_relative '../db/matches'
require_relative '../db/match_predictions'
require_relative '../db/predictions'
require_relative '../db/users'

class App < Sinatra::Application
  extend DBEmails
  extend DBMatches
  extend DBMatchPredictions
  extend DBPredictions
  extend DBUsers

  get '/match/:match_id' do
    require_signed_in_user
    match_id = params[:match_id].to_i
    render_match(match_id)
  end

  post '/match/add_prediction' do
    require_signed_in_user
    match_id = params[:match_id].to_i
    home_prediction = params[:home_team_prediction].to_f
    away_prediction = params[:away_team_prediction].to_f
    move_next = to_bool?(params[:next])
    load_match_details(match_id)
    return render_match(match_id) unless validate_prediction?(home_prediction,
                                                              away_prediction)
    add_prediction(
      session[:user_id],
      match_id,
      home_prediction.to_i,
      away_prediction.to_i
    )
    session[:message] = 'Prediction submitted'
    session[:message_level] = 'success'
    match_id = @next_match[:match_id] if move_next
    redirect redirect_url(match_id, move_next:)
  end

  post '/match/add_result' do
    require_signed_in_as_admin
    match_id = params[:match_id].to_i
    home_score = params[:home_score].to_f
    away_score = params[:away_score].to_f
    load_match_details(match_id)
    return render_match(match_id) unless validate_result?(home_score,
                                                          away_score)
    home_score = home_score.to_i
    away_score = away_score.to_i
    add_result(
      match_id, home_score, away_score, session[:user_id]
    )
    update_scoreboard(match_id, home_score, away_score)
    send_result_email(match_id)
    session[:message] = 'Result submitted'
    session[:message_level] = 'success'
    redirect redirect_url(match_id)
  end

  post '/match/broadcaster/edit' do
    require_signed_in_as_admin
    match_id = params[:match_id].to_i
    broacaster_id = params[:broadcaster].to_i
    change_broadcaster(match_id, broacaster_id)
    data = { message: "Broadcaster changed", status: "success" }
    data.to_json
  end

  get '/match/:match_id/predictions' do
    require_signed_in_user
    match_id = params[:match_id].to_i
    payload = match_predictions_payload(match_id)
    halt 404 if payload.nil?
    content_type :json
    payload.to_json
  end

  private

  def render_match(match_id)
    load_match_details(match_id)
    @match[:locked_down] = match_locked_down?(@match)
    if @match[:locked_down]
      @users = load_all_users_details
      @predictions = get_match_predictions(match_id, 1)
    end
    if origin?(@match)
      @origin = match_origin(match_id)
    end
    if user_is_admin?
      @broadcasters = broadcasters_query
    end
    erb :match
  end

  def validate_prediction?(home, away)
    session[:message] = prediction_error(@match, home, away)
    if session[:message]
      session[:message_level] = 'danger'
      status 422
      return false
    end
    true
  end

  def validate_result?(home, away)
    session[:message] = match_result_error(@match, home, away)
    if session[:message]
      session[:message_level] = 'danger'
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
    @match = load_single_match(session[:user_id], match_id)
    @result = !@match[:home_score].nil?
    load_ring
    return unless origin?(@match)
    @origin = match_origin(match_id)
  end

  def load_ring
    return if params[:ring].nil? || params[:ring] == ""
    @ring = Ring.new({ ring: params[:ring] })
    @prev_match = @ring.prev_match
    @next_match = @ring.next_match
  end

  def to_bool?(str)
    str == 'true'
  end

  def send_result_email(match_id)
    match = load_single_match(1, match_id)
    predictions = get_match_predictions(match_id)
    table = load_scoreboard_data('Official')[:overall_table]
    subject = result_email_subject(match)
    body = result_email_body(match, predictions, table)
    send_email_all(
      subject:,
      body:
    )
    record_results_email_sent(match_id)
  end

  def result_email_subject(match)
    "Results for #{home_name(match)} vs. #{away_name(match)}"
  end

  def result_email_body(match, predictions, table)
    erb :'email/result',
        layout: false,
        locals: { match:, predictions:, table: }
  end

  def match_predictions_payload(match_id)
    load_match_details(match_id)
    return nil unless @match[:locked_down] || match_locked_down?(@match)

    {
      match: {
        home_name: home_name(@match),
        away_name: away_name(@match),
        home_score: @match[:home_score],
        away_score: @match[:away_score]
      },
      predictions: get_match_predictions(match_id, 1).map do |prediction|
        {
          name: prediction[:user],
          home: prediction[:home_prediction],
          away: prediction[:away_prediction]
        }
      end
    }
  end
end
