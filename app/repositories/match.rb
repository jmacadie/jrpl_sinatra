class MatchRepository
  def initialize(query_runner:)
    @query_runner = query_runner
  end

  def add_result(match_id, home_team_points, away_team_points, user_id)
    sql = update_match_table_query()
    @query_runner.run_query(sql,
                            home_team_points,
                            away_team_points,
                            user_id,
                            Time.now,
                            match_id)
  end

  def load_single_match(user_id, match_id)
    sql = single_match_query()
    result = @query_runner.run_query(sql, user_id, match_id)
    result.map { |row| row_to_matches_details_hash(row) }.first
  end

  private

  def convert_str_to_int(str)
    # This is needed because nil.to_i returns 0!!!
    str&.to_i
  end

  def to_datetime(date, time)
    base_date = Time.parse(date)
    base_time = Time.parse(time)
    base_time_in_s =
      (base_time.hour * 3600) +
      (base_time.min * 60) +
      (base_time.sec)
    base_date + base_time_in_s
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

  # Standalone SQL
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

  def single_match_query
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
      broadcaster.name AS broadcaster,
      predictions.home_team_points AS home_team_prediction,
      predictions.away_team_points AS away_team_prediction
    FROM match
      INNER JOIN tournament_role AS home_tr ON match.home_team_id = home_tr.tournament_role_id
      INNER JOIN tournament_role AS away_tr ON match.away_team_id = away_tr.tournament_role_id
      LEFT OUTER JOIN team AS home_team ON home_tr.team_id = home_team.team_id
      LEFT OUTER JOIN team AS away_team ON away_tr.team_id = away_team.team_id
      INNER JOIN venue ON match.venue_id = venue.venue_id
      INNER JOIN stage ON match.stage_id = stage.stage_id
      INNER JOIN broadcaster ON match.broadcaster_id = broadcaster.broadcaster_id
      LEFT OUTER JOIN
        (SELECT
            prediction.match_id,
            prediction.home_team_points,
            prediction.away_team_points
          FROM prediction
          WHERE prediction.user_id = $1::int)
          AS predictions ON predictions.match_id = match.match_id
    WHERE match.match_id = $2::int
    ORDER BY
      match.date,
      match.kick_off,
      match.match_id;
    SQL
  end
end
