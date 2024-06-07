# rubocop:disable Metrics/ModuleLength
module DBPersMatchesFull
  def get_matches_full(criteria, user_id=1)
    sql = matches_full_query(criteria)
    result = query(sql, user_id)
    map_full_results(result)
  end

  private

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def map_full_results(result)
    result.map do |tuple|
      { match_id: tuple['match_id'].to_i,
        match_date: tuple['date'],
        kick_off: tuple['kick_off'],
        match_datetime: to_datetime(tuple['date'], tuple['kick_off']),
        home_score: convert_str_to_int(tuple['home_team_points']),
        away_score: convert_str_to_int(tuple['away_team_points']),
        home_prediction: convert_str_to_int(tuple['home_team_prediction']),
        away_prediction: convert_str_to_int(tuple['away_team_prediction']),
        home_name: tuple['home_team_name'],
        home_tournament_role: tuple['home_tournament_role'],
        home_short_name: tuple['home_team_short_name'],
        away_name: tuple['away_team_name'],
        away_tournament_role: tuple['away_tournament_role'],
        away_short_name: tuple['away_team_short_name'],
        stage: tuple['stage'],
        venue: tuple['venue'] }
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  def matches_full_query(criteria)
    out = []
    out << matches_full_start
    where_txt = all_criteria(criteria)
    if !where_txt.empty?
      out << 'WHERE'
      out << where_txt
      out << ''
    end
    out << matches_full_end
    out.join("\n")
  end

  def matches_full_start
    <<~SQL
    SELECT
      m.match_id,
      m.date,
      m.kick_off,
      pred.home_team_points AS home_team_prediction,
      pred.away_team_points AS away_team_prediction,
      m.home_team_points,
      m.away_team_points,
      hot.name AS home_team_name,
      hot.short_name AS home_team_short_name,
      awt.name AS away_team_name,
      awt.short_name AS away_team_short_name,
      htr.name AS home_tournament_role,
      atr.name AS away_tournament_role,
      stage.name AS stage,
      venue.name AS venue

    FROM match AS m
      INNER JOIN tournament_role AS htr ON m.home_team_id = htr.tournament_role_id
      INNER JOIN tournament_role AS atr ON m.away_team_id = atr.tournament_role_id
        LEFT JOIN meta_group mg ON htr.from_group_id = mg.meta_group_id AND m.stage_id = 1
        LEFT JOIN meta_group_map mgm ON mgm.meta_group_id = mg.meta_group_id
        LEFT JOIN base_group g ON g.group_id = mgm.group_id
      LEFT OUTER JOIN team AS hot ON htr.team_id = hot.team_id
      LEFT OUTER JOIN team AS awt ON atr.team_id = awt.team_id
      INNER JOIN venue ON m.venue_id = venue.venue_id
      INNER JOIN stage ON m.stage_id = stage.stage_id
      LEFT OUTER JOIN
        (SELECT
            prediction.match_id,
            prediction.home_team_points,
            prediction.away_team_points
          FROM prediction
          WHERE prediction.user_id = $1::int)
          AS pred ON pred.match_id = m.match_id
    SQL
  end

  def matches_full_end
    <<~SQL
    ORDER BY
      m.date ASC,
      m.kick_off ASC;
    SQL
  end

  def all_criteria(criteria)
    out = []
    out << played_criteria if criteria[:exclude_played]
    out << predicted_criteria if criteria[:exclude_predicted]
    stages_txt = stages_criteria(criteria[:stages], criteria[:groups])
    out << stages_txt if !stages_txt.empty?
    out.join(" AND\n")
  end

  def played_criteria
    "(m.home_team_points IS NULL AND m.away_team_points IS NULL)"
  end

  def predicted_criteria
    "(pred.home_team_points IS NULL AND pred.away_team_points IS NULL)"
  end

  def stages_criteria(stages, groups)
    stages_txt = stage_list(stages)
    groups_txt = groups_list(stages, groups)
    if !stages_txt.nil? && !groups_txt.nil?
      "(#{stages_txt} OR #{groups_txt})"
    else
      groups_txt || stages_txt || ""
    end
  end

  # rubocop:disable Metrics/MethodLength
  def stage_list(stages)
    # rubocop:disable Layout/HashAlignment
    stage_map = {
      round16:       "'Round of 16'",
      quarter_final: "'Quarter Finals'",
      semi_final:    "'Semi Finals'",
      final:         "'Final'"
    }
    # rubocop:enable Layout/HashAlignment
    list = stages.except(:group)
                 .filter { |_, v| v }
                 .map { |k, _| stage_map[k] }
                 .join(', ')
    return nil if list.empty?
    "(stage.name IN (#{list}))"
  end
  # rubocop:enable Metrics/MethodLength

  def groups_list(stages, groups)
    return nil if !stages[:group]
    list = groups.filter { |_, v| v }
                 .map { |k, _| "'#{k}'" }
                 .join(', ')
    return nil if list.empty?
    "(stage.name = 'Group Stages' AND g.name IN (#{list}))"
  end
end
# rubocop:enable Metrics/ModuleLength
