# rubocop:todo Metrics/ModuleLength
module DBMatches
  def add_result(match_id, home_team_points, away_team_points, user_id)
    sql = update_match_table_query()
    query(sql, home_team_points, away_team_points, user_id, Time.now, match_id)
  end

  # rubocop:disable Metrics/AbcSize
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

    result.map do |row|
      row['match_id'].to_i
    end
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize
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

    result.map do |row|
      row_to_matches_details_hash(row)
    end
  end
  # rubocop:enable Metrics/AbcSize

  def load_all_matches(user_id)
    sql = construct_all_matches_query()
    result = query(sql, user_id)
    result.map { |row| row_to_matches_details_hash(row) }
  end

  def load_single_match(user_id, match_id)
    sql = construct_single_match_query()
    result = query(sql, user_id, match_id)
    result.map { |row| row_to_matches_details_hash(row) }.first
  end

  def match_result(match_id)
    sql = match_result_query()
    result = query(sql, match_id)
    result.map do |row|
      { home_score: row['home_team_points'].to_i,
        away_score: row['away_team_points'].to_i }
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
    result.map do |row|
      { match_id: row['match_id'].to_i,
        match_date: row['date'],
        kick_off: row['kick_off'],
        match_datetime: to_datetime(row['date'], row['kick_off']) }
    end
  end

  def match_origin(match_id)
    sql = match_origin_query()
    result = query(sql, match_id)
    result.map { |row| row_to_origin_details_hash(row) }.first
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
    @stage_names ||= tournament_stage_names()
    number_of_stages = @stage_names.size
    while criteria[:tournament_stages].size < number_of_stages
      criteria[:tournament_stages] << ''
    end
  end

  # rubocop:disable Metrics/AbcSize
  def row_to_matches_details_hash(row)
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
      venue: row['venue'],
      city: row['city'],
      broadcaster: row['broadcaster'] }
  end
  # rubocop:enable Metrics/AbcSize

  def row_to_origin_details_hash(row)
    {
      ht_home_team: row['ht_home_team'],
      ht_away_team: row['ht_away_team'],
      ht_home_team_s: row['ht_home_team_s'],
      ht_away_team_s: row['ht_away_team_s'],
      ht_home_team_points: row['ht_home_team_points'],
      ht_away_team_points: row['ht_away_team_points'],
      ht_match_id: row['ht_match_id'],
      ht_stage: row['ht_stage'],
      at_home_team: row['at_home_team'],
      at_away_team: row['at_away_team'],
      at_home_team_s: row['at_home_team_s'],
      at_away_team_s: row['at_away_team_s'],
      at_home_team_points: row['at_home_team_points'],
      at_away_team_points: row['at_away_team_points'],
      at_match_id: row['at_match_id'],
      at_stage: row['at_stage']
    }
  end
  # Standalone SQL
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  def match_result_query
    <<~SQL
    SELECT
      home_team_points,
      away_team_points
    FROM match
    WHERE match_id = $1::int;
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
      home_team_points = $1::int,
      away_team_points = $2::int,
      result_posted_by = $3::int,
      result_posted_on = $4::date
    WHERE match_id = $5::int;
    SQL
  end

  def match_origin_query
    <<~SQL
    SELECT
      COALESCE(htht.name, httrht.name) AS ht_home_team,
      COALESCE(htat.name, httrat.name) AS ht_away_team,
      htht.short_name AS ht_home_team_s,
      htat.short_name AS ht_away_team_s,
      htm.home_team_points AS ht_home_team_points,
      htm.away_team_points AS ht_away_team_points,
      htm.match_id AS ht_match_id,
      hts.name AS ht_stage,
      COALESCE(atht.name, attrht.name) AS at_home_team,
      COALESCE(atat.name, attrat.name) AS at_away_team,
      atht.short_name AS at_home_team_s,
      atat.short_name AS at_away_team_s,
      atm.home_team_points AS at_home_team_points,
      atm.away_team_points AS at_away_team_points,
      atm.match_id AS at_match_id,
      ats.name AS at_stage

    FROM match m

      INNER JOIN tournament_role trht ON
        trht.tournament_role_id = m.home_team_id
      LEFT JOIN match htm ON
        htm.match_id = trht.from_match_id
      LEFT JOIN stage hts ON
        hts.stage_id = htm.stage_id
      LEFT JOIN tournament_role httrht ON
        httrht.tournament_role_id = htm.home_team_id
      LEFT JOIN team htht ON
        htht.team_id = httrht.team_id
      LEFT JOIN tournament_role httrat ON
        httrat.tournament_role_id = htm.away_team_id
      LEFT JOIN team htat ON
        htat.team_id = httrat.team_id

      INNER JOIN tournament_role trat ON
        trat.tournament_role_id = m.away_team_id
      LEFT JOIN match atm ON
        atm.match_id = trat.from_match_id
      LEFT JOIN stage ats ON
        ats.stage_id = atm.stage_id
      LEFT JOIN tournament_role attrht ON
        attrht.tournament_role_id = atm.home_team_id
      LEFT JOIN team atht ON
        atht.team_id = attrht.team_id
      LEFT JOIN tournament_role attrat ON
        attrat.tournament_role_id = atm.away_team_id
      LEFT JOIN team atat ON
        atat.team_id = attrat.team_id

    WHERE m.match_id = $1::int;
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
      venue.city AS city,
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
    WHERE match.match_id = $2::int
    SQL
  end

  def tournament_stages_clause
    <<-SQL
  AND (stage.name IN ($3::text, $4::text, $5::text, $6::text, $7::text, $8::text))
    SQL
  end

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
