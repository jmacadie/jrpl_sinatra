# rubocop:todo Metrics/ModuleLength
module DBPersMatches
  def add_result(match_id, home_team_points, away_team_points, user_id)
    sql = update_match_table_query()
    query(sql, home_team_points, away_team_points, user_id, Time.now, match_id)
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def filter_matches_list(user_id, criteria, lockdown)
    add_empty_strings_for_stages_for_exec_params(criteria)

    sql = construct_filter_matches_list_query(criteria)

    result = query(
      sql,
      lockdown[:date],
      lockdown[:time],
      criteria[:tournament_stages][0],
      criteria[:tournament_stages][1],
      criteria[:tournament_stages][2],
      criteria[:tournament_stages][3],
      criteria[:tournament_stages][4],
      criteria[:tournament_stages][5],
      user_id
    )

    result.map do |tuple|
      tuple['match_id'].to_i
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def filter_matches(user_id, criteria, lockdown)
    add_empty_strings_for_stages_for_exec_params(criteria)

    sql = construct_filter_matches_details_query(criteria)

    result = query(
      sql,
      lockdown[:date],
      lockdown[:time],
      criteria[:tournament_stages][0],
      criteria[:tournament_stages][1],
      criteria[:tournament_stages][2],
      criteria[:tournament_stages][3],
      criteria[:tournament_stages][4],
      criteria[:tournament_stages][5],
      user_id
    )

    result.map do |tuple|
      tuple_to_matches_details_hash(tuple)
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def load_all_matches(user_id)
    sql = construct_all_matches_query()
    result = query(sql, user_id)
    result.map do |tuple|
      tuple_to_matches_details_hash(tuple)
    end
  end

  def load_single_match(user_id, match_id)
    sql = construct_single_match_query()
    result = query(sql, user_id, match_id)
    result.map do |tuple|
      tuple_to_matches_details_hash(tuple)
    end.first
  end

  def match_result(match_id)
    sql = match_result_query()
    result = query(sql, match_id)
    result.map do |tuple|
      { home_score: tuple['home_team_points'].to_i,
        away_score: tuple['away_team_points'].to_i }
    end.first
  end

  def max_match_id
    sql = 'SELECT max(match_id) FROM match;'
    query(sql).first['max'].to_i
  end

  def min_match_id
    sql = 'SELECT min(match_id) FROM match;'
    query(sql).first['min'].to_i
  end

  def lockdown_matches
    sql = lockdown_match_query()
    result = query(sql)
    result.map do |tuple|
      { match_id: tuple['match_id'].to_i,
        match_date: tuple['date'],
        kick_off: tuple['kick_off'],
        match_datetime: to_datetime(tuple['date'], tuple['kick_off']) }
    end
  end

  private

  def to_datetime(date, time)
    base_date = Time.parse(date)
    base_time = Time.parse(time)
    base_time_in_s =
      (base_time.hour * 3600) +
      (base_time.min * 60) +
      (base_time.sec)
    base_date + base_time_in_s
  end

  def add_empty_strings_for_stages_for_exec_params(criteria)
    number_of_stages = tournament_stage_names.size
    while criteria[:tournament_stages].size < number_of_stages
      criteria[:tournament_stages] << ''
    end
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def tuple_to_matches_details_hash(tuple)
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
      venue: tuple['venue'],
      broadcaster: tuple['broadcaster'] }
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  # Standalone SQL
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  def match_result_query
    <<~SQL
    SELECT
      home_team_points,
      away_team_points
    FROM match
    WHERE match_id = $1;
    SQL
  end

  def lockdown_match_query
    <<~SQL
    SELECT
      m.match_id,
      m.date,
      m.kick_off
    FROM match m
      INNER JOIN emails e ON
        e.match_id = m.match_id
    WHERE e.predictions_sent = false
    ORDER BY m.match_id ASC;
    SQL
  end

  def update_match_table_query
    <<~SQL
    UPDATE match
    SET
      home_team_points = $1,
      away_team_points = $2,
      result_posted_by = $3,
      result_posted_on = $4
    WHERE match_id = $5;
    SQL
  end

  # SQL builders
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  def construct_all_matches_query
    [
      select_match_details_clause(),
      select_user_predictions_clause(),
      from_match_details_clause(),
      predictions_for_single_user_single_or_all_matches_clause(),
      order_clause()
    ].join()
  end

  def construct_filter_matches_details_query(criteria)
    [
      select_match_details_clause(),
      from_match_details_clause(),
      predictions_for_single_user_filter_clause(),
      "WHERE\n",
      lockdown_clause(criteria[:match_status]),
      tournament_stages_clause(),
      predictions_clause(criteria[:prediction_status]),
      order_clause()
    ].join()
  end

  def construct_filter_matches_list_query(criteria)
    [
      select_match_id_clause(),
      from_match_details_clause(),
      predictions_for_single_user_filter_clause(),
      "WHERE\n",
      lockdown_clause(criteria[:match_status]),
      tournament_stages_clause(),
      predictions_clause(criteria[:prediction_status]),
      order_clause()
    ].join()
  end

  def construct_single_match_query
    [
      select_match_details_clause(),
      select_user_predictions_clause(),
      from_match_details_clause(),
      predictions_for_single_user_single_or_all_matches_clause(),
      where_single_match_clause(),
      order_clause()
    ].join()
  end

  # SELECT clauses
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  def select_match_id_clause
    <<~SQL
    SELECT
      match.match_id
    SQL
  end

  def select_match_details_clause
    <<~SQL
    SELECT
      match.match_id,
      match.date,
      match.kick_off,
      predictions.home_team_points AS home_team_prediction,
      predictions.away_team_points AS away_team_prediction,
      match.home_team_points,
      match.away_team_points,
      home_team.name AS home_team_name,
      home_team.short_name AS home_team_short_name,
      away_team.name AS away_team_name,
      away_team.short_name AS away_team_short_name,
      home_tr.name AS home_tournament_role,
      away_tr.name AS away_tournament_role,
      stage.name AS stage,
      venue.name AS venue,
      broadcaster.name AS broadcaster
    SQL
  end

  def select_user_predictions_clause
    <<-SQL
  ,
  predictions.home_team_points AS home_team_prediction,
  predictions.away_team_points AS away_team_prediction
    SQL
  end

  # FROM clauses
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  def from_match_details_clause
    <<~SQL
    FROM match
      INNER JOIN tournament_role AS home_tr ON match.home_team_id = home_tr.tournament_role_id
      INNER JOIN tournament_role AS away_tr ON match.away_team_id = away_tr.tournament_role_id
      LEFT OUTER JOIN team AS home_team ON home_tr.team_id = home_team.team_id
      LEFT OUTER JOIN team AS away_team ON away_tr.team_id = away_team.team_id
      INNER JOIN venue ON match.venue_id = venue.venue_id
      INNER JOIN stage ON match.stage_id = stage.stage_id
      INNER JOIN broadcaster ON match.broadcaster_id = broadcaster.broadcaster_id
    SQL
  end

  def predictions_for_single_user_filter_clause
    <<-SQL
  LEFT OUTER JOIN
    (SELECT
        prediction.match_id,
        prediction.home_team_points,
        prediction.away_team_points
      FROM prediction
      WHERE prediction.user_id = $9::int)
      AS predictions ON predictions.match_id = match.match_id
    SQL
  end

  def predictions_for_single_user_single_or_all_matches_clause
    <<-SQL
  LEFT OUTER JOIN
    (SELECT
        prediction.match_id,
        prediction.home_team_points,
        prediction.away_team_points
      FROM prediction
      WHERE prediction.user_id = $1::int)
      AS predictions ON predictions.match_id = match.match_id
    SQL
  end

  # WHERE clauses
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  def where_single_match_clause
    <<~SQL
    WHERE match.match_id = $2
    SQL
  end

  def tournament_stages_clause
    <<-SQL
  AND (stage.name IN ($3::text, $4::text, $5::text, $6::text, $7::text, $8::text))
    SQL
  end

  # rubocop:disable Metrics/MethodLength
  def lockdown_clause(match_status)
    case match_status
    when 'locked_down'
      <<-SQL
  (date < $1::date OR (date = $1::date AND kick_off < $2::time))
      SQL
    when 'not_locked_down'
      <<-SQL
  (date > $1::date OR (date = $1::date AND kick_off >= $2::time))
      SQL
    else
      <<-SQL
  ($1 != $2) -- all locked down statuses: always true!
      SQL
    end
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def predictions_clause(prediction_status)
    case prediction_status
    when 'predicted'
      <<-SQL
  AND (predictions.match_id IS NOT NULL)
      SQL
    when 'not_predicted'
      <<-SQL
  AND (predictions.match_id IS NULL)
      SQL
    else
      ''
    end
  end
  # rubocop:enable Metrics/MethodLength

  # ORDER BY clauses
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  def order_clause
    <<~SQL
    ORDER BY
      match.date,
      match.kick_off,
      match.match_id;
    SQL
  end
end
# rubocop:enable Metrics/ModuleLength
