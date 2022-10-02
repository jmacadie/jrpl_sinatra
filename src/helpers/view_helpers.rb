module ViewHelpers
  def home_team_name(match)
    match[:home_team_name] || match[:home_tournament_role]
  end

  def away_team_name(match)
    match[:away_team_name] || match[:away_tournament_role]
  end

  def home_team_prediction(match)
    match[:home_team_prediction] || 'no prediction'
  end

  def away_team_prediction(match)
    match[:away_team_prediction] || 'no prediction'
  end

  def home_team_points(match)
    match[:home_pts] || 'no result'
  end

  def away_team_points(match)
    match[:away_pts] || 'no result'
  end

  def match_locked_down?(match)
    match_date_time = "#{match[:match_date]} #{match[:kick_off]}"
    (Time.now + App::LOCKDOWN_BUFFER) > Time.parse(match_date_time)
  end

  def previous_match(match_id)
    match_list = load_match_list()
    current_match_index = match_list.index { |match| match == match_id }
    current_match_index ||= 1
    previous_match_index = current_match_index - 1
    if previous_match_index < 0
      nil
    else
      match_list[previous_match_index]
    end
  end

  def next_match(match_id)
    match_list = load_match_list()
    max_index = match_list.size - 1
    current_match_index = match_list.index { |match| match == match_id }
    current_match_index ||= 1
    next_match_index = current_match_index + 1
    if next_match_index > max_index
      nil
    else
      match_list[next_match_index]
    end
  end
end
