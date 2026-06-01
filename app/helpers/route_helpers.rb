require_relative '../repositories/matches'

module RouteHelpers
  extend DBMatches

  def extract_search_criteria(params)
    tournament_stages = params.select do |_, v|
      v == 'tournament_stage'
    end.keys
    { match_status: params[:match_status],
      prediction_status: params[:prediction_status],
      tournament_stages: }
  end

  def load_matches
    lockdown = calculate_lockdown()
    filter_matches(session[:user_id], session[:criteria], lockdown)
  end

  def load_match_list
    lockdown = calculate_lockdown()
    filter_matches_list(
      session[:user_id],
      session[:criteria],
      lockdown
    )
  end

  def calculate_lockdown
    lockdown_timedate = Time.now + App::LOCKDOWN_BUFFER
    lockdown_date = lockdown_timedate.strftime("%Y-%m-%d")
    lockdown_time = lockdown_timedate.strftime("%k:%M:%S")
    { date: lockdown_date, time: lockdown_time }
  end

  def match_locked_down?(match)
    match_date_time = "#{match[:match_date]} #{match[:kick_off]}"
    (Time.now + App::LOCKDOWN_BUFFER) > Time.parse(match_date_time)
  end

  def set_criteria_to_all_matches
    { match_status: 'all',
      prediction_status: 'all',
      tournament_stages: tournament_stage_names() }
  end

  def tournament_stage_names
    @tournament_stage_names ||= tournament_stage_names_query
  end
end
