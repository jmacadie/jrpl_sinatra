require_relative '../repositories/emails'
require_relative '../repositories/matches'

class App < Sinatra::Application
  extend DBEmails
  extend DBMatches

  get '/match/:match_id' do
    require_signed_in_user
    match_id = params[:match_id].to_i
    render_match(match_id)
  end

  post '/match/add_prediction' do
    require_signed_in_user
    match_id = params[:match_id].to_i
    home_prediction = params[:home_team_prediction]
    away_prediction = params[:away_team_prediction]
    move_next = to_bool?(params[:next])
    result = MatchPredictionService.new(
      match_id:,
      home_prediction:,
      away_prediction:,
      user_id: session[:user_id],
      operations: settings.match_prediction_operations
    ).call
    return render_error(match_id, result) unless result.success?

    load_ring
    session[:message] = 'Prediction submitted'
    session[:message_level] = 'success'
    match_id = @next_match[:match_id] if move_next
    redirect redirect_url(match_id, move_next:)
  end

  post '/match/add_result' do
    require_signed_in_as_admin
    match_id = params[:match_id].to_i
    home_score = params[:home_score]
    away_score = params[:away_score]
    result = MatchResultService.new(
      match_id:,
      home_score:,
      away_score:,
      user_id: session[:user_id],
      operations: settings.match_result_operations
    ).call
    return render_error(match_id, result) unless result.success?

    load_ring
    session[:message] = 'Result submitted'
    session[:message_level] = 'success'
    redirect redirect_url(match_id)
  end

  post '/match/broadcaster/edit' do
    require_signed_in_as_admin
    match_id = params[:match_id].to_i
    broadcaster_id = params[:broadcaster].to_i
    result = settings.match_broadcaster_service.call(
      match_id:,
      broadcaster_id:
    )
    content_type :json
    { message: result.message, status: result.status }.to_json
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
    load_ring
    assign_match_page(
      settings.match_page_service.call(
        match_id:,
        user_id: session[:user_id],
        admin: user_is_admin?
      )
    )
    erb :match
  end

  def assign_match_page(page)
    @match = page.match
    @result = page.result
    @users = page.users
    @predictions = page.predictions
    @origin = page.origin
    @broadcasters = page.broadcasters
  end

  def render_error(match_id, result)
    session[:message] = result.message
    session[:message_level] = 'danger'
    status 422
    render_match(match_id)
  end

  def redirect_url(match_id, move_next: false)
    root = "/match/#{match_id}"
    return root if @ring.nil?
    return "#{root}?ring=#{@ring}" unless move_next
    "#{root}?ring=#{@next_match[:ring]}"
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

  def match_predictions_payload(match_id)
    page = settings.match_page_service.call(
      match_id:,
      user_id: session[:user_id],
      admin: false
    )
    match = page.match
    return nil unless match[:locked_down]

    {
      match: {
        home_name: home_name(match),
        away_name: away_name(match),
        home_score: match[:home_score],
        away_score: match[:away_score]
      },
      predictions: predictions_payload(page.predictions)
    }
  end

  def predictions_payload(predictions)
    predictions.map do |prediction|
      {
        name: prediction[:user],
        home: prediction[:home_prediction],
        away: prediction[:away_prediction]
      }
    end
  end
end
