class FixturesRepository
  def initialize(query_runner:)
    @query_runner = query_runner
  end

  def load_matches(criteria, user_id)
    result = @query_runner.run_query(matches_query(criteria), user_id)
    result.map { |row| row_to_match(row) }
  end

  def stage_names
    result = @query_runner.run_query('SELECT name FROM stage;')
    result.map { |row| row['name'] }
  end

  private

  # rubocop:disable Metrics/AbcSize
  def row_to_match(row)
    { match_id: row['match_id'].to_i,
      match_date: row['date'],
      kick_off: row['kick_off'],
      match_datetime: to_datetime(row['date'], row['kick_off']),
      home_score: convert_str_to_int(row['home_team_points']),
      away_score: convert_str_to_int(row['away_team_points']),
      home_prediction: convert_str_to_int(row['home_team_prediction']),
      away_prediction: convert_str_to_int(row['away_team_prediction']),
      home_name: row['home_team_name'],
      home_tournament_role: row['home_tournament_role'],
      home_short_name: row['home_team_short_name'],
      away_name: row['away_team_name'],
      away_tournament_role: row['away_tournament_role'],
      away_short_name: row['away_team_short_name'],
      stage: row['stage'],
      venue: row['venue'] }
  end
  # rubocop:enable Metrics/AbcSize

  def convert_str_to_int(value)
    value&.to_i
  end

  def to_datetime(date, time)
    base_date = Time.parse(date)
    base_time = Time.parse(time)
    base_time_in_s =
      (base_time.hour * 3600) +
      (base_time.min * 60) +
      base_time.sec
    base_date + base_time_in_s
  end

  def matches_query(criteria)
    query = [matches_query_start]
    where = all_criteria(criteria)
    query.push('WHERE', where, '') unless where.empty?
    query << matches_query_end
    query.join("\n")
  end

  def matches_query_start
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

  def matches_query_end
    <<~SQL
      ORDER BY
        m.date ASC,
        m.kick_off ASC;
    SQL
  end

  def all_criteria(criteria)
    conditions = []
    conditions << played_criteria if criteria[:exclude_played]
    conditions << predicted_criteria if criteria[:exclude_predicted]
    stages = stages_criteria(criteria[:stages], criteria[:groups])
    conditions << stages unless stages.empty?
    conditions.join(" AND\n")
  end

  def played_criteria
    "(m.home_team_points IS NULL AND m.away_team_points IS NULL)"
  end

  def predicted_criteria
    "(pred.home_team_points IS NULL AND pred.away_team_points IS NULL)"
  end

  def stages_criteria(stages, groups)
    stages_text = stage_list(stages)
    groups_text = groups_list(stages, groups)
    return "(#{stages_text} OR #{groups_text})" if stages_text && groups_text

    groups_text || stages_text || ""
  end

  def stage_list(stages)
    stage_map = {
      round32: "'Round of 32'",
      round16: "'Round of 16'",
      quarter_final: "'Quarter Finals'",
      semi_final: "'Semi Finals'",
      final: "'Third Fourth Place Play-off', 'Final'"
    }
    list = stages.except(:group)
                 .filter { |_, selected| selected }
                 .map { |stage, _| stage_map[stage] }
                 .join(', ')
    return nil if list.empty?

    "(stage.name IN (#{list}))"
  end

  def groups_list(stages, groups)
    return nil unless stages[:group]

    list = groups.filter { |_, selected| selected }
                 .map { |group, _| "'#{group}'" }
                 .join(', ')
    return nil if list.empty?

    "(stage.name = 'Group Stages' AND g.name IN (#{list}))"
  end
end
