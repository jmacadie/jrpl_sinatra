# rubocop:todo Metrics/ModuleLength
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
    @match_list ||= load_match_list()
    current_match_index = @match_list.index { |match| match == match_id }
    current_match_index ||= 1
    previous_match_index = current_match_index - 1
    if previous_match_index < 0
      nil
    else
      @match_list[previous_match_index]
    end
  end

  def next_match(match_id)
    @match_list ||= load_match_list()
    max_index = @match_list.size - 1
    current_match_index = @match_list.index { |match| match == match_id }
    current_match_index ||= 1
    next_match_index = current_match_index + 1
    if next_match_index > max_index
      nil
    else
      @match_list[next_match_index]
    end
  end

  # rubocop:disable Metrics/MethodLength
  def date_for_print(match)
    dt = Date.parse(match[:match_date])
    suffix =
      case dt.mday
      when 1, 11, 21
        'st'
      when 2, 22
        'nd'
      when 3, 23
        'rd'
      else
        'th'
      end
    dt.strftime("%A, %-d#{suffix} %B %Y")
  end
  # rubocop:enable Metrics/MethodLength

  def ring_for_url(ring)
    "?ring=#{ring}"
  end

  def link_for_ring_navigation(match)
    "/match/#{match[:match_id]}?ring=#{match[:ring]}"
  end

  def kick_off_for_print(match)
    t = match[:kick_off]
    Time.parse(t).strftime('%k:%M')
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def prediction_for_print(match)
    out = []
    if predicted?(match)
      out.push '<strong>'
      out.push predicted_result(match)
      out.push '</strong>'
      out.push '<br />'
      if match[:home_prediction] > match[:away_prediction]
        out.push home_prediction(match)
        out.push ' - '
        out.push away_prediction(match)
      else
        out.push away_prediction(match)
        out.push ' - '
        out.push home_prediction(match)
      end
    else
      out.push '<em>'
      out.push 'No prediction'
      out.push '</em>'
    end
    out.join()
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def points_for_print(prediction)
    if prediction[:total_points].nil? ||
       prediction[:total_points] == 0
      '-'
    else
      prediction[:total_points].to_s
    end
  end

  # rubocop:disable Metrics/MethodLength
  def page
    case request.path_info
    when %r(^/fixtures)
      "fixtures"
    when %r(^/match)
      "match"
    when %r(^/users)
      "users"
    when %r(^/scoreboard)
      "tables"
    when %r(^/graphs)
      "graphs"
    when %r(^/rules)
      "rules"
    else
      ""
    end
  end
  # rubocop:enable Metrics/MethodLength
end
# rubocop:enable Metrics/ModuleLength
