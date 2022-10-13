module DBPersMatchPredictions
  def get_match_predictions(match_id, scoring_system=1)
    sql = match_predictions_query()
    result = query(sql, match_id, scoring_system)
    map_results(result)
  end

  private

  # rubocop:disable Metrics/MethodLength
  def map_results(result)
    result.map do |tuple|
      { user: tuple['user_name'],
        home_name: tuple['home_team_name'],
        home_tournament_role: tuple['home_tournament_role'],
        away_name: tuple['away_team_name'],
        away_tournament_role: tuple['away_tournament_role'],
        home_prediction: convert_str_to_int(tuple['home_team_points']),
        away_prediction: convert_str_to_int(tuple['away_team_points']),
        result_points: convert_str_to_int(tuple['result_points']),
        score_points: convert_str_to_int(tuple['score_points']),
        total_points: convert_str_to_int(tuple['total_points']) }
    end
  end
  # rubocop:enable Metrics/MethodLength

  def match_predictions_query
    <<~SQL
    WITH match_predictions AS
      (SELECT
        pd.prediction_id,
        pd.user_id,
        hot.name AS home_team_name,
        htr.name AS home_tournament_role,
        awt.name AS away_team_name,
        atr.name AS away_tournament_role,
        pd.home_team_points,
        pd.away_team_points
      FROM prediction pd
        INNER JOIN match m ON
          m.match_id = pd.match_id
        INNER JOIN tournament_role htr ON
          htr.tournament_role_id = m.home_team_id
          LEFT JOIN team hot ON
            hot.team_id = htr.team_id
        INNER JOIN tournament_role atr ON
          atr.tournament_role_id = m.away_team_id
          LEFT JOIN team awt ON
            awt.team_id = atr.team_id
      WHERE pd.match_id = $1::int),

    match_points AS
      (SELECT
        points.prediction_id,
        points.result_points,
        points.score_points,
        points.total_points
      FROM points
        INNER JOIN prediction ON
          prediction.prediction_id = points.prediction_id
      WHERE
        prediction.match_id = $1::int
        AND points.scoring_system_id = $2::int)

    SELECT
      u.user_name,
      mpr.home_team_points,
      mpr.away_team_points,
      mpr.home_team_name,
      mpr.home_tournament_role,
      mpr.away_team_name,
      mpr.away_tournament_role,
      mpo.result_points,
      mpo.score_points,
      mpo.total_points
    FROM users u
      LEFT JOIN match_predictions mpr ON
        mpr.user_id = u.user_id
      LEFT JOIN match_points mpo ON
        mpo.prediction_id = mpr.prediction_id
    ORDER BY
      mpo.total_points DESC NULLS LAST,
      (mpr.home_team_points - mpr.away_team_points) DESC NULLS LAST,
      mpr.home_team_points DESC NULLS LAST;
    SQL
  end
end
