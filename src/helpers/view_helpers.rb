module ViewHelpers
  def home_name(match)
    match[:home_name] || match[:home_tournament_role]
  end

  def away_name(match)
    match[:away_name] || match[:away_tournament_role]
  end

  def predicted?(match)
    !match[:home_prediction].nil? &&
      !match[:away_prediction].nil?
  end

  def knockout?(match)
    match[:stage] != 'Group Stages'
  end

  def home_prediction(match)
    match[:home_prediction] || 'no prediction'
  end

  def away_prediction(match)
    match[:away_prediction] || 'no prediction'
  end

  def predicted_result(match)
    return 'No prediction' unless predicted?(match)
    if match[:home_prediction] > match[:away_prediction]
      "#{home_name(match)} Win"
    elsif match[:away_prediction] > match[:home_prediction]
      "#{away_name(match)} Win"
    else
      "Draw"
    end
  end

  def home_score(match)
    match[:home_score] || ''
  end

  def away_score(match)
    match[:away_score] || ''
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

  def date_for_print(match)
    dt = match[:match_date]
    Date.parse(dt).strftime('%A, %-d %B')
  end

  def kick_off_for_print(match)
    t = match[:kick_off]
    Time.parse(t).strftime('%k:%M')
  end

  # rubocop:disable Metrics/MethodLength
  def page
    case request.path_info
    when %r(^/matches)
      "matches"
    when %r(^/match)
      "match"
    when %r(^/users)
      "users"
    when %r(^/scoreboard)
      "tables"
    when %r(^/graphs)
      "graphs"
    else
      ""
    end
  end
  # rubocop:enable Metrics/MethodLength
end
