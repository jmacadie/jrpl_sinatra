module ViewHelpers
  def home_name(match)
    Presenters::MatchTeams.new(match:).home_name
  end

  def away_name(match)
    Presenters::MatchTeams.new(match:).away_name
  end

  def predicted?(match)
    !match[:home_prediction].nil? &&
      !match[:away_prediction].nil?
  end

  def knockout?(match)
    match[:stage] != 'Group Stages'
  end

  def origin?(match)
    knockout?(match) && match[:stage] != 'Round of 32'
  end

  def home_prediction(match)
    match[:home_prediction] || 'no prediction'
  end

  def away_prediction(match)
    match[:away_prediction] || 'no prediction'
  end

  def home_flag(match)
    flag_css(match[:home_short_name], false)
  end

  def away_flag(match)
    flag_css(match[:away_short_name], false)
  end

  def flag_css(name, small)
    name ||= 'TMP'
    if small
      "team-flag-sm flag-#{name}"
    else
      "team-flag flag-#{name}"
    end
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

  def authenticity_token
    Rack::Protection::AuthenticityToken.token(env['rack.session'])
  end

  def checked_if(actual, expected: true)
    attribute_if(actual == expected, ' checked')
  end

  def selected_if(actual, expected: true)
    attribute_if(actual == expected, ' selected')
  end

  def disabled_if(condition)
    attribute_if(condition, ' disabled')
  end

  def active_if(actual, expected)
    attribute_if(actual == expected, ' active')
  end

  def attribute_if(condition, attribute)
    condition ? attribute : nil
  end

  def origin_details(origin, prefix)
    {
      match_id: origin[:"#{prefix}_match_id"],
      stage: origin[:"#{prefix}_stage"],
      home_team_short_name: origin[:"#{prefix}_home_team_s"],
      home_team: origin[:"#{prefix}_home_team"],
      home_team_points: origin[:"#{prefix}_home_team_points"],
      away_team_short_name: origin[:"#{prefix}_away_team_s"],
      away_team: origin[:"#{prefix}_away_team"],
      away_team_points: origin[:"#{prefix}_away_team_points"]
    }
  end

  def date_for_print(match)
    dt = Date.parse(match[:match_date])
    suffix =
      case dt.mday
      when 1, 21
        'st'
      when 2, 22
        'nd'
      when 3, 23
        'rd'
      else
        'th'
      end
    dt.strftime("%A, %-d<sup>#{suffix}</sup> %B %Y")
  end

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
        out.push '&nbsp;-&nbsp;'
        out.push away_prediction(match)
      else
        out.push away_prediction(match)
        out.push '&nbsp;-&nbsp;'
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

  def points_for_print(points)
    if points.nil? ||
       points == 0
      '-'
    else
      points.to_s
    end
  end

  def prediction_points_for_print(prediction)
    points_for_print(prediction[:total_points])
  end

  def page
    case request.path_info
    when %r(^/fixtures)
      "fixtures"
    when %r(^/match)
      "match"
    when %r(^/users)
      "users"
    when %r(^/tables)
      "tables"
    when %r(^/graphs)
      "graphs"
    when %r(^/rules)
      "rules"
    else
      ""
    end
  end

  def camelcase(string, initial=:ignore)
    delimiters = Regexp.union(['-', '_', ' ', '/', '\\'])
    case initial
    when :upper
      string.split(delimiters).map(&:capitalize).join
    when :lower
      string.split(delimiters).then do |first, *rest|
        [first.downcase, rest.map(&:capitalize)].join
      end
    else
      string.split(delimiters).then do |first, *rest|
        [first, rest.map(&:capitalize)].join
      end
    end
  end
end
