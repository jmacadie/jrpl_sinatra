class PredictionRepository
  def initialize(query_runner:)
    @query_runner = query_runner
  end

  def get_predictions_results(match_id, scoring_system=1)
    result = @query_runner.run_query(match_predictions_query,
                                     match_id,
                                     scoring_system)
    map_results(result)
  end

  def predictions_for_match(match_id)
    result = @query_runner.run_query(predictions_for_match_query, match_id)
    result.map do |row|
      { pred_id: row['prediction_id'].to_i,
        home_score: row['home_team_points'].to_i,
        away_score: row['away_team_points'].to_i }
    end
  end

  def add_prediction(user_id, match_id, home_team_points, away_team_points)
    delete_prediction(user_id, match_id)
    @query_runner.run_query(
      insert_prediction_query,
      user_id,
      match_id,
      home_team_points,
      away_team_points
    )
  end

  private

  def delete_prediction(user_id, match_id)
    @query_runner.run_query(delete_prediction_query, user_id, match_id)
  end

  def predictions_for_match_query
    <<~SQL
      SELECT
        prediction_id,
        home_team_points,
        away_team_points
      FROM prediction
      WHERE match_id = $1::int;
    SQL
  end

  def delete_prediction_query
    <<~SQL
      DELETE FROM prediction
      WHERE user_id = $1::int AND match_id = $2::int;
    SQL
  end

  def insert_prediction_query
    <<~SQL
      INSERT INTO prediction
        (user_id, match_id, home_team_points, away_team_points)
      VALUES ($1::int, $2::int, $3::int, $4::int);
    SQL
  end

  def convert_str_to_int(str)
    str&.to_i
  end

  def map_results(result)
    result.map do |row|
      { user: row['user_name'],
        home_name: row['home_team_name'],
        home_tournament_role: row['home_tournament_role'],
        away_name: row['away_team_name'],
        away_tournament_role: row['away_tournament_role'],
        home_prediction: convert_str_to_int(row['home_team_points']),
        away_prediction: convert_str_to_int(row['away_team_points']),
        result_points: convert_str_to_int(row['result_points']),
        score_points: convert_str_to_int(row['score_points']),
        total_points: convert_str_to_int(row['total_points']) }
    end
  end

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
